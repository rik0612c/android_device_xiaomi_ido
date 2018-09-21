LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := sensors.$(TARGET_DEVICE)

LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_PROPRIETARY_MODULE := true

LOCAL_CFLAGS := -Wall -Werror -DLOG_TAG=\"MultiHal\"

LOCAL_SRC_FILES := \
    multihal.cpp \
    SensorEventQueue.cpp \

LOCAL_HEADER_LIBRARIES := \
    libhardware_headers \

LOCAL_SHARED_LIBRARIES := \
    libcutils \
    libdl \
    liblog \
    libutils \

include $(BUILD_SHARED_LIBRARY)
