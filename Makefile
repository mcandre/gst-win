AIP=gst-3.2.90.aip

all: installer

installer: $(AIP)
	AdvancedInstaller /build $(AIP)
