THEOS_DEVICE_IP = 192.168.2.62
ARCHS = armv7 arm64
debug = 0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PullClearBulletin
$(TWEAK_NAME)_FILES = Tweak.xm \
							MJRefresh/Custom/Header/MJRefreshGifHeader.m \
							MJRefresh/Custom/Header/MJRefreshNormalHeader.m \
							MJRefresh/Custom/Header/MJRefreshStateHeader.m \
							\
							MJRefresh/Custom/Footer/Auto/MJRefreshAutoGifFooter.m \
							MJRefresh/Custom/Footer/Auto/MJRefreshAutoNormalFooter.m \
							MJRefresh/Custom/Footer/Auto/MJRefreshAutoStateFooter.m \
							\
							MJRefresh/Custom/Footer/Back/MJRefreshBackGifFooter.m \
							MJRefresh/Custom/Footer/Back/MJRefreshBackNormalFooter.m \
							MJRefresh/Custom/Footer/Back/MJRefreshBackStateFooter.m \
							\
							MJRefresh/Base/MJRefreshAutoFooter.m \
							MJRefresh/Base/MJRefreshBackFooter.m \
							MJRefresh/Base/MJRefreshComponent.m \
							MJRefresh/Base/MJRefreshFooter.m \
							MJRefresh/Base/MJRefreshHeader.m \
							\
							MJRefresh/MJRefreshConst.m \
							MJRefresh/NSBundle+MJRefresh.m \
							MJRefresh/UIScrollView+MJExtension.m \
							MJRefresh/UIScrollView+MJRefresh.m \
							MJRefresh/UIView+MJExtension.m \

$(TWEAK_NAME)_CFLAGS = -w -fobjc-arc
$(TWEAK_NAME)_CFLAGS += -I MJRefresh/Custom/Header/
$(TWEAK_NAME)_CFLAGS += -I MJRefresh/Custom/Footer/Auto/
$(TWEAK_NAME)_CFLAGS += -I MJRefresh/Custom/Footer/Back/
$(TWEAK_NAME)_CFLAGS += -I MJRefresh/Base/
$(TWEAK_NAME)_CFLAGS += -I MJRefresh/

include $(THEOS_MAKE_PATH)/tweak.mk

before-package::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceBundles/$(TWEAK_NAME)$(ECHO_END)
	$(ECHO_NOTHING)rsync -avC MJRefresh/MJRefresh.bundle $(THEOS_STAGING_DIR)/Library/PreferenceBundles/$(TWEAK_NAME)$(ECHO_END)

after-install::
	install.exec "killall -9 SpringBoard"



