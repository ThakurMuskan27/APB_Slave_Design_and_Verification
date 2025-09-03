
#Makefile

RTL= ..\RTL\apb_change.v
TB= ..\TB\apb_tb.v
TOP= apb_tb

COV_EN=0

lb:
	vlib work

cmp: 
	vlog +acc $(RTL) $(TB)

cmp_coverage:
	vlog -coveropt 3 +cover +acc $(RTL) $(TB)

sim_cmd:
	vsim -voptargs=+acc $(TOP) -c -do "run -all; exit"

sim:
	vsim -voptargs=+acc $(TOP) -do "run -all;"

sim_coverage:
	vsim -coverage -voptargs=+acc $(TOP) -c -do "coverage save -onexit -directive -cvg -codeall ALU_TEST_cov.ucdb; run -all; exit" -l TEST.log
	vcover report -details -html ALU_TEST_cov.ucdb -htmldir ALU_COV	

ifeq ($(COV_EN),1)
run: cmp_coverage sim_coverage
else
run: cmp sim
endif

run_cmd: cmp sim_cmd 
