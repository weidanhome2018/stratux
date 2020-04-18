
ifeq "$(CIRCLECI)" "true"
	BUILDINFO=
	PLATFORMDEPENDENT=
else
	LDFLAGS_VERSION=-X main.stratuxVersion=`git describe --tags --abbrev=0` -X main.stratuxBuild=`git log -n 1 --pretty=%H`
	BUILDINFO=-ldflags "$(LDFLAGS_VERSION)"
	BUILDINFO_STATIC=-ldflags "-extldflags -static $(LDFLAGS_VERSION)"
#$(if $(GOROOT),,$(error GOROOT is not set!))
	PLATFORMDEPENDENT=
endif

all:
	make xdump978 xdump1090 xgen_gdl90 $(PLATFORMDEPENDENT)

xgen_gdl90:
	go get -t -d -v ./main ./godump978 ./uatparse ./sensors
	go build $(BUILDINFO) -p 4 main/gen_gdl90.go main/traffic.go main/gps.go main/network.go main/managementinterface.go main/sdr.go main/ping.go main/uibroadcast.go main/monotonic.go main/datalog.go main/equations.go main/sensors.go main/cputemp.go

fancontrol:
	go get -t -d -v ./main
	go build $(BUILDINFO_STATIC) -p 4 main/fancontrol.go main/equations.go main/cputemp.go

xdump1090:
	git submodule update --init
	cd dump1090 && make

xdump978:
	cd dump978 && make lib
	cp -f ./libdump978.so /usr/lib/libdump978.so

.PHONY: test
test:
	make -C test	

www:
	cd web && make

install:
	make www
	cp -f libdump978.so /usr/lib/libdump978.so
	cp -f dump1090/dump1090 /usr/bin/

clean:
	rm -f gen_gdl90 libdump978.so fancontrol ahrs_approx
	cd dump1090 && make clean
	cd dump978 && make clean
