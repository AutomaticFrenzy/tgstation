//this needs to come after the job_types subfolder to keep the correct ordering

#define MAP_JOB_CHECK if(SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) { return; }
#define MAP_JOB_CHECK_BASE if(SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) { return ..(); }
#define MAP_REMOVE_JOB(jobpath) /datum/job/##jobpath/map_check() { return (SSmapping.config.map_name != JOB_MODIFICATION_MAP_NAME) && ..() }

#include "..\..\..\..\_maps\map_files\SBStation\job_changes.dm"
#undef JOB_MODIFICATION_MAP_NAME

#include "..\..\..\..\_maps\map_files\FrenzyStation\job_changes.dm"
#undef JOB_MODIFICATION_MAP_NAME
