#!/usr/bin/env python3
import collections
import frontend
import dmm
import re

def check_maintloot(M):
    # Format of this map parsing
    # dict(coordinates->mapkey)
    grid = M.grid
    # dict(mapkey->tilecontents)
    dictionary = M.dictionary
    # tilecontents are a list of atoms, path is first

    lootdrop_path = "/obj/effect/spawner/lootdrop/maintenance"
    area_path = "/area"

    follow_up = set()
    for key, atoms in dictionary.items():
        #atom is a string
        for atom in atoms:
            if atom.startswith(lootdrop_path):
                if key in follow_up:
                    print(f"Hey, ({key}) has multiple maintlootdrops...")
                follow_up.add(key)

    # Count the number of times each map key appears
    appears = collections.Counter()
    for coord, key in grid.items():
        if key in follow_up:
            appears[key] += 1

    tally = collections.Counter()
    for key in follow_up:
        # Because I am a terrible person, and don't actually care about
        # building a proper parser for this "object notation" that byond
        # uses, I'm just going to cheat.
        area = None
        count = 0

        for atom in dictionary[key]:
            if atom.startswith(lootdrop_path):
                amount = 1
                mo = re.search(r'lootcount = (\d+)', atom)
                if mo is not None:
                    amount = int(mo.group(1))
                count += amount

            elif atom.startswith(area_path):
                area = atom

        # Multiply by the number of times this model is used
        tally[area] += (count * appears[key])

    for area, total in tally.items():
        print("{}: {}".format(area, total))

    print("TOTAL: {}".format(sum(tally.values())))

def main(settings):
    for fname in frontend.process(settings, "maintloot check", modify=False):
        check_maintloot(dmm.DMM.from_file(fname))

if __name__ == '__main__':
    main(frontend.read_settings())
