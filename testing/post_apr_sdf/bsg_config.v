config bsg_config;
  design `BSG_DESIGNS_TESTING_LIBRARY_NAME.`BSG_TOP_SIM_MODULE;
  default liblist `BSG_DESIGNS_TESTING_LIBRARY_NAME work;
  instance `BSG_CHIP_INSTANCE_PATH liblist `BSG_CHIP_LIBRARY_NAME;
endconfig
