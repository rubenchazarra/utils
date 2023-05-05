#!/bin/bash

# This is a wrapper for job submission into SLURM queueing system. Originally developed by @Raquel Garcia. Modifications by @Ruben Chazarra Gil.

arg0=$(basename "$0" .sh)
blnk=$(echo "$arg0" | sed 's/./ /g')

usage_info()
{
    echo "Usage: $arg0 {-j|--job}"
    echo "       $blnk {-o|--output_dir}"
    echo "       $blnk {-r|--ref_dir}"
    echo "       $blnk {-N|--nodes}"
    echo "       $blnk {-n|--ntasks}"
    echo "       $blnk {-u|--cpus-per-task}"
    echo "       $blnk {-tn|--tasks-per-node}"
    echo "       $blnk {-q|--qos}"
    echo "       $blnk {-t|--time}"
    echo "       $blnk {-mem|--mem_constraint}"
    echo "       $blnk {-a|--array}"
    echo "       $blnk {-af|--array_file}"
    echo "       $blnk {-g|--greasy}"
    echo "       $blnk {-gf|--greasy_file}"
    echo "       $blnk {-c|--command}"
    echo "       $blnk {-arg1|--argument_1}"
    echo "       $blnk {-arg2|--argument_2}"
    echo "       $blnk {-arg3|--argument_3}"
    echo "       $blnk {-arg4|--argument_4}"
    echo "       $blnk {-arg5|--argument_5}"
    echo "       $blnk {-arg6|--argument_6}"
}

usage()
{
    exec 1> std.out   # Send standard output to standard output
    #exec 1>2   # Send standard output to standard error
    usage_info
    exit 1
}

error()
{
    echo "$arg0: $*" >&2
    exit 1
}

help()
{
    usage_info
    echo
    echo "  {-j|--job} job                          Choose job to perform"
    echo "  {-o|--output_dir} output_dir            Set output directory (default: current directory)"
    echo "  {-r|--ref_dir} ref_dir                  Set reference directory (default: current directory)"
    echo "  {-N|--nodes} number_of_nodes            Set number of nodes (default: 1)"
    echo "  {-n|--ntasks} number_of_tasks           Set number of processes to start (default: 1)"
    echo "  {-u|--cpus-per-task} cpus_per_task      Set number of cpus per task (default: 1)" # The number of cores assigned to the job will be the total_tasks number * cpus_per_task number
    echo "  {-tn|--tasks-per-node} tasks_per_node   Set the number of tasks assigned to a node (default: 1)"
    echo "  {-q|--qos} queue                        Set queue (default: debug)"
    echo "  {-t|--time} wall_clock                  Set wall clock (default: 00:01:00)"
    echo "  {-mem|--mem_constraint}                 Memory constraint. Can be one of: '', 'medmem' (Nord3v2) and 'highmem' (MareNostrum4, Nord3v2)"
    echo "  {-a|--array} array                      Array (True or False)  (default: 'False')"
    echo "  {-af|--array_file} array_file           Input array file (default: '')"
    echo "  {-g|--greasy} greasy                    Whether to run with Greasy (BSC internal paralellisation software) (default: 'False')"
    echo "  {-gf|--greasy_file} greasy_file         Input Greasy file (default: '')"
    echo "  {-c|--command} command                  Command (default: 'echo  'Hello world!')" # command line, Rscript, bash script
    echo "  {-arg1|--argument_1} argument_1         Argument 1 (default: '')" # should be a file if job is an array
    echo "  {-arg2|--argument_2} argument_2         Argument 2 (default: '')"
    echo "  {-arg3|--argument_3} argument_3         Argument 3 (default: '')"
    echo "  {-arg4|--argument_4} argument_4         Argument 4 (default: '')"
    echo "  {-arg5|--argument_5} argument_5         Argument 5 (default: '')"
    echo "  {-arg6|--argument_6} argument_6         Argument 6 (default: '')"
    echo "  {-arg7|--argument_7} argument_7         Argument 7 (default: '')"
    echo "  {-arg8|--argument_8} argument_8         Argument 8 (default: '')"
    echo "  {-h|--help}                             Print this help message and exit"
    echo " "
    echo "  # Provide full paths"
    echo "  Output structure:"
    echo "  ---- output_dir
                  ---- logs
                       ---- outputs
                       ---- errors
                  ---- scripts"
#   echo "  {-V|--version}                  -- Print version information and exit"
    exit 0
}

flags()
{
    OPTCOUNT=0
    JOB=""
    OUTPUT_DIR=`pwd` # to make current directory the default output folder
    REF_DIR=`$(pwd)/logs` # make this the default reference directory
    N_NODES=1
    N_TASKS=1
    N_CPUS=1
    CPU_TASK=1
    QUEUE="debug"
    WALL_CLOCK="00:01:00"
    MEM=""
    ARRAY="False"
    ARRAY_FILE=""
    GREASY="False"
    GREASY_FILE=""
    COMMAND=`echo "echo 'Hello world'"`
    ARG1=""
    ARG2=""
    ARG3=""
    ARG4=""
    ARG5=""
    ARG6=""

    while test $# -gt 0
    do
        case "$1" in
        (-j|--job)
            shift
            [ $# = 0 ] && error "No job specified"
            export JOB=`echo $1`
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-o|--output_dir)
            shift
            [ $# = 0 ] && error "No output_dir specified"
            export OUTPUT_DIR=${1%/}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-r|--ref_dir)
            shift
            [ $# = 0 ] && error "No ref_dir specified"
            export REF_DIR=${1%/}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-N|--nodes)
            shift
            [ $# = 0 ] && error "No number_of_nodes specified"
            export N_NODES=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-n|--ntasks)
            shift
            [ $# = 0 ] && error "No number_of_tasks specified"
            export N_TASKS=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-u|--cpus-per-task)
            shift
            [ $# = 0 ] && error "No cpus_per_task specified"
            export N_CPUS=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-tn|--tasks-per-node)
            shift
            [ $# = 0 ] && error "No tasks_per_node specified"
            export CPU_TASK=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-q|--qos)
            shift
            [ $# = 0 ] && error "No queue specified"
            export QUEUE=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-t|--time)
            shift
            [ $# = 0 ] && error "No wall_clock specified"
            export WALL_CLOCK=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-mem|--mem_constraint)
            shift
            [ $# = 0 ] && error "No memory constraint specified"
            export MEM=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-a|--array)
            shift
            [ $# = 0 ] && error "No array specified"
            export ARRAY=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-af|--array_file)
            shift
            [ $# = 0 ] && error "No file specified"
            export ARRAY_FILE=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-g|--greasy)
            shift
            [ $# = 0 ] && error "No greasy specified"
            export GREASY=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-gf|--greasy_file)
            shift
            [ $# = 0 ] && error "No greasy file specified"
            export GREASY_FILE=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-c|--command)
            shift
            [ $# = 0 ] && error "No command specified"
            export COMMAND=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-arg1|--argument_1)
            shift
            [ $# = 0 ] && error "No argument_1 specified"
            export ARG1=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-arg2|--argument_2)
            shift
            [ $# = 0 ] && error "No argument_2 specified"
            export ARG2=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-arg3|--argument_3)
            shift
            [ $# = 0 ] && error "No argument_3 specified"
            export ARG3=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-arg4|--argument_4)
            shift
            [ $# = 0 ] && error "No argument_4 specified"
            export ARG4=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-arg5|--argument_5)
            shift
            [ $# = 0 ] && error "No argument_5 specified"
            export ARG5=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-arg6|--argument_6)
            shift
            [ $# = 0 ] && error "No argument_6 specified"
            export ARG6=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-arg7|--argument_7)
            shift
            [ $# = 0 ] && error "No argument_7 specified"
            export ARG6=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-arg8|--argument_8)
            shift
            [ $# = 0 ] && error "No argument_8 specified"
            export ARG6=${1}
            shift
            OPTCOUNT=$(($OPTCOUNT + 2));;
        (-h|--help)
            help;;
#       (-V|--version)
#           version_info;;
        (--)
            shift
            OPTCOUNT=$(($OPTCOUNT + 1))
            break;;
        (*) usage;;
        esac
    done
    #echo "DEBUG-1: [$*]" >&2
    #echo "OPTCOUNT=$OPTCOUNT" >&2
}

flags "$@"
#echo "DEBUG-2: [$*]" >&2
#echo "OPTCOUNT=$OPTCOUNT" >&2
shift $OPTCOUNT
#echo "DEBUG-3: [$*]" >&2

#Static variables
LOG_FOLDER=$OUTPUT_DIR'/logs';
scripts_folder=$OUTPUT_DIR'/scripts';

#Create the required folders:
#echo "Create output directories"
mkdir -p $OUTPUT_DIR
mkdir -p $LOG_FOLDER #; mkdir -p $LOG_FOLDER/outputs; mkdir -p $LOG_FOLDER/errors
mkdir -p $scripts_folder

echo "######################"
date
echo ""
version=1.0; echo "version="$version;
SLEEP=false; #echo "  SLEEP="$SLEEP;

echo ""
echo "-----------------------"
echo "job: $JOB"
#echo "input_dir: $INPUT_DIR"
echo "output_dir: $OUTPUT_DIR"
echo "ref_dir: $REF_DIR"
echo "LOG_FOLDER: $LOG_FOLDER"
echo "scripts_folder: $scripts_folder"

if [ $ARRAY == "True" ]; then
  echo "Job is an array"
fi

if [ $GREASY == "True" ]; then
  echo "Job run with Greasy"
fi

echo "-----------------------"
echo ""
echo "#######################"
echo ""

# JOB Type

# Three type of jobs are considered: 
# 1) Standard Job
# 2) Array Job
# 3) Greasy Job


# Arrays
# Array and  Greasy cannot be ran together 
if [ $ARRAY == "True" ] && [ $GREASY == "True" ];then
    echo "ARRAY and GREASY cannot be run together. Killing submission..."
    exit
elif [ $ARRAY == "False" ]  && [ $GREASY == "False" ];then
    echo "Standard Job"
    JOB_TYPE="standard"
elif [ $ARRAY == "True" ]  && [ $GREASY == "False" ];then
    echo "Array Job"
    JOB_TYPE="array"
    
elif [ $ARRAY == "False" ]  && [ $GREASY == "True" ];then
    echo "Greasy Job"
    JOB_TYPE="greasy"
fi

## Node Memory (Normal, Medium or High) # Checks
mem_values=("" "medmem" "highmem")
mem_values_print=("NOTHING (Do not specify)" "medmem" "highmem")

if [[ ! " ${mem_values[*]} " =~ " ${MEM} " ]]; then
    echo "ERROR: Memory constraint variable: $MEM must be one of ${mem_values_print[@]}"
    #exit 1
fi

# 1) Standard Job: No Array,  No Greasy
if [ $JOB_TYPE == "standard" ] ;then

# Write sbatch script
echo "#!/bin/bash

#SBATCH --job-name=$JOB
#SBATCH --output=$LOG_FOLDER/slurm-%j-${JOB}.out
#SBATCH --error=$LOG_FOLDER/slurm-%j-${JOB}.err
#SBATCH --chdir=$REF_DIR
#SBATCH --nodes=$N_NODES
#SBATCH --ntasks=$N_TASKS
#SBATCH --cpus-per-task=$N_CPUS
#SBATCH --tasks-per-node=$CPU_TASK
#SBATCH --qos=$QUEUE
#SBATCH --time=$WALL_CLOCK
#SBATCH --constraint=$MEM

echo '----------------------'
date
echo '----------------------'
echo ' '

$COMMAND $ARG1 $ARG2 $ARG3 $ARG4 $ARG5 $ARG6

echo ' '
echo '----------------------'
date
echo '----------------------'
echo ' '
" > $scripts_folder/slurm-${JOB}.sbatch.sh # Note: cannot incorporate $SLURM_JOB_ID to script file name cause this is an sbatch internal variable!
# Run sbatch script
sbatch  $scripts_folder/slurm-${JOB}.sbatch.sh

# 2) ARRAY JOB
elif [ $JOB_TYPE == "array" ];then

N_ITERATIONS=`cat $ARRAY_FILE| wc -l`
N_ARGS=`awk '{print NF}' $ARRAY_FILE | sort -nu | tail -n 1`

echo "#!/bin/bash

#SBATCH --job-name=$JOB
#SBATCH --output=$LOG_FOLDER/slurm-%A_%a-${JOB}.out
#SBATCH --error=$LOG_FOLDER/slurm-%A_%a-${JOB}.err
#SBATCH --chdir=$REF_DIR
#SBATCH --nodes=$N_NODES
#SBATCH --ntasks=$N_TASKS
#SBATCH --cpus-per-task=$N_CPUS
#SBATCH --tasks-per-node=$CPU_TASK
#SBATCH --qos=$QUEUE
#SBATCH --time=$WALL_CLOCK
#SBATCH --constraint=$MEM
#SBATCH --array=1-$N_ITERATIONS

echo '----------------------'
date
echo '----------------------'
echo ' '

$COMMAND \\" > $scripts_folder/slurm-${JOB}.sbatch.sh

for i in `seq ${N_ARGS}`;
do
  # Explanation of this command: sed prints the nth line of array file and cut extrats the i-th argument of the array file separated by tab (default for cut, we can specify a different character with cut -d$' ')
  echo "\`sed -n \${SLURM_ARRAY_TASK_ID}p \$ARRAY_FILE | cut -f${i}\` \\" >> $scripts_folder/slurm-${JOB}.sbatch.sh
done;

echo "

echo ' '
echo '----------------------'
date
echo '----------------------'
echo ' '

" >> $scripts_folder/slurm-${JOB}.sbatch.sh
sbatch $scripts_folder/slurm-${JOB}.sbatch.sh

# 3) GREASY JOB
# TODO --> Specify greasy log and greasy restart file (.rst) location --> I think that comes from greasy.conf which is readonly
# TODO --> If command argument -c is empty, the dafault value is ' Hello World '. I would like to enable the -c command to be emtpy if job is a GREASY JOB
# Note: exlcuded '--tasks-per-node' option here, since this is captured automatically by greasy
elif [ $JOB_TYPE == "greasy" ];then

# N of tasks corresponds to the N of lines in GREASY_FILE
N_TASKS=$(wc -l < "$GREASY_FILE")

echo "#!/bin/bash

#SBATCH --job-name=$JOB
#SBATCH --output=$LOG_FOLDER/slurm-%j-${JOB}.out
#SBATCH --error=$LOG_FOLDER/slurm-%j-${JOB}.err
#SBATCH --chdir=$REF_DIR
#SBATCH --nodes=$N_NODES
#SBATCH --ntasks=$N_TASKS
#SBATCH --cpus-per-task=$N_CPUS
#SBATCH --qos=$QUEUE
#SBATCH --time=$WALL_CLOCK
#SBATCH --constraint=$MEM

echo '----------------------'
date
echo '----------------------'
echo ' '

# Load Greasy
module load greasy

# NOTE: HOW CAN I SPECIFY THE LOCATION OF THE greasy.log AND  greasy.rst file
#GREASY_LOGFILE="$LOG_FOLDER/slurm-${SLURM_JOB_ID}-greasy.log"
#echo $GREASY_LOGFILE
#export $GREASY_LOGFILE

# Note: \$GREASY_FILE includes the full commands to be launched
greasy $GREASY_FILE 

echo ' '
echo '----------------------'
date
echo '----------------------'
echo ' '

" > $scripts_folder/slurm-${JOB}-greasy.sbatch.sh

sbatch $scripts_folder/slurm-${JOB}-greasy.sbatch.sh

fi

########
