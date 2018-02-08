package com.sinlov.aubnig.test.demo.widget;

import android.widget.Toast;

import com.sinlov.aubnig.test.demo.data.RandomString;
import com.sinlov.aubnig.test.demo.needchange.R;

import org.junit.Test;
import org.robolectric.shadows.ShadowToast;

import test.RobolectricTemp;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

/**
 * <pre>
 *     sinlov
 *
 *     /\__/\
 *    /`    '\
 *  ≈≈≈ 0  0 ≈≈≈ Hello world!
 *    \  --  /
 *   /        \
 *  /          \
 * |            |
 *  \  ||  ||  /
 *   \_oo__oo_/≡≡≡≡≡≡≡≡o
 *
 * </pre>
 * Created by sinlov on 2018/2/8.
 */
public class TestToast extends RobolectricTemp {

    @Override
    public void setUp() throws Exception {
        super.setUp();
    }

    @Test
    public void test_01_show_toast_success() throws Exception {
        // mock
        String message = RandomString.generateLowerString(8);
        // do show
        Toast.makeText(application, message, Toast.LENGTH_SHORT).show();
        // verify
        assertTrue("test_01_show_toast_success", ShadowToast.getTextOfLatestToast().contains(message));
    }

    @Test
    public void test_02_show_toast_fail() throws Exception {
        // mock
        String message = RandomString.generateLowerString(8);
        // do not show
        Toast.makeText(application, message, Toast.LENGTH_SHORT);
        // verify
        String latestToast = ShadowToast.getTextOfLatestToast();
        assertEquals("test_02_show_toast_fail", STRING_NULL, latestToast);
    }

    @Test
    public void test_03_show_message_by_id() throws Exception {
        // mock
        String app_name = application.getString(R.string.app_name);
        // do
        Toast.makeText(application, R.string.app_name, Toast.LENGTH_SHORT).show();
        // verify
        String latestToast = ShadowToast.getTextOfLatestToast();
        assertEquals("test_03_show_message_by_id", app_name, latestToast);
    }
}
