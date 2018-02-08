package com.sinlov.android.plugintemp;

import android.app.Application;

/**
 * for test Shadow Application
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
public class TestApplication extends Application {

    private int initCount = 0;

    @Override
    public void onCreate() {
        super.onCreate();
        if (initCount < 1) {
            // TODO: sinlov init you want at application
        }
        initCount++;
    }
}
