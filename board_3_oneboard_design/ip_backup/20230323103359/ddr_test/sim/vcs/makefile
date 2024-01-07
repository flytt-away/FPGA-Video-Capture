FUNC_DEF = +neg_tchk
COMPILE_TOOL = vcs +systemverilogext+.sv+vpi -sverilog +v2k -ntb_opts dtm
COMPILE_OPTS = +vcsd +vcs+lic+wait -lca -R
COMPILE_OPTS += -full64 -P ${Verdi_HOME}/share/PLI/VCS/linux64/novas.tab
COMPILE_OPTS += ${Verdi_HOME}/share/PLI/VCS/linux64/pli.a
COMPILE_OPTS += -negdelay
COMPILE_OPTS += +define+FSDB
COMPILE_OPTS += -l ./sim.log
COMPILE_OPTS += ${FUNC_DEF}

.PHONY:clean run_all
run_all:
	${COMPILE_TOOL} ${COMPILE_OPTS} -f ./sim_file_list.f
clean:
	rm -rf *.log verdiLog simv.daidir novas.* csrc sdf_* simv ucli.key *.vf *.fsdb*
