export NAME=`basename $0`

# MODE not defined or defined to something else than 'batch'
if [[ -z ${MODE+x} ]] || [[ ! "$MODE" =~ "batch" ]]; then MODE="gui";fi
MODE="-"${MODE##*-} #remove any eventual extra dashes

case "$SIMULATOR" in
	modelsim)
  		# ModelSim flow
  		vlib work
  		vlog ${SOURCE} || exit 1
		vsim ${NAME} -do "add log /* -r; run -a" $MODE -logfile ${NAME}_modelsim.log || exit 1
		;;

	xsim)
		# XSim flow
		xvlog -log ${NAME}_xvlog.log --sourcelibdir . ${SOURCE}
		xelab -log ${NAME}_xelab.log -debug all ${NAME}
		if [[ "$MODE" == "-gui" ]]; then
			echo "run all" > xsim_gui_cmd.tcl
			xsim work.${NAME} -gui -tclbatch xsim_gui_cmd.tcl -log ${NAME}_xsim.log
		else
			xsim work.${NAME} -R -log ${NAME}_xsim.log
		fi
		;;

	xcelium)
		# Xcelium flow
		xmvlog -NOWARN NONPRT ${SOURCE} || exit 1
		xmelab -access +rc ${NAME}
		xmsim ${NAME} -gui || exit 1
		;;

	*)
		#Icarus flow is the default
		mkdir -p run
		mkdir -p vcd
		iverilog -o run/run_${NAME} -I.. ${SOURCE} $1 || exit 1
		cd vcd
		../run/run_${NAME}
		;;
esac

