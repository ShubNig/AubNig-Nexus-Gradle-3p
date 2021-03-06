package com.sinlov.aubnig.test.demo.ux;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.support.annotation.IdRes;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

/**
 * For test of Temp
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
 * Created by sinlov on 2017/12/14.
 */

public abstract class TempTestActivity extends AppCompatActivity {

    protected String TAG;

    private long testTimeUse;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = TempTestActivity.class.getSimpleName().replace("Activity", "");
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        processLogic(savedInstanceState);
    }

    /**
     * process logic and resumes states etc.
     *
     * @param savedInstanceState {@link Bundle}
     */
    protected abstract void processLogic(Bundle savedInstanceState);

    /**
     * @param id   widget id
     * @param <VT> View
     * @return extends {@link View}
     */
    @SuppressWarnings("unchecked")
    protected <VT extends View> VT getViewById(@IdRes int id) {
        return (VT) findViewById(id);
    }

    protected void showToast(String text) {
        Toast.makeText(this.getApplicationContext(), text, Toast.LENGTH_SHORT).show();
    }

    protected void showToast(int id) {
        Toast.makeText(this.getApplicationContext(), id, Toast.LENGTH_SHORT).show();
    }

    protected void skip2Activity(Class<?> cls) {
        skip2Activity(cls, null);
    }

    protected void skip2Activity(Class<?> cls, Bundle bundle) {
        Intent intent = new Intent(TempTestActivity.this, cls);
        if (null != bundle) {
            intent.putExtras(bundle);
        }
        startActivity(intent);
    }

    protected void testTimeUseStart() {
        testTimeUse = System.currentTimeMillis();
    }

    protected long testTimeUseEnd() {
        long useTime = System.currentTimeMillis() - testTimeUse;
        Log.d(TAG, "testTimeUse: " + useTime);
        return useTime;
    }
}
