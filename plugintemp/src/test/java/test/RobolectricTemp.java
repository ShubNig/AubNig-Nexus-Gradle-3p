package test;

import android.content.Context;
import android.os.Build;

import com.sinlov.android.plugintemp.BuildConfig;
import com.sinlov.android.plugintemp.TestApplication;

import org.junit.After;
import org.junit.Before;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.RuntimeEnvironment;
import org.robolectric.annotation.Config;

/**
 * <li>child class must set Working directory with $MODULE_DIR$ when in develop</li>
 * <p>
 * code
 * <pre>
 *  $MODULE_DIR$
 * </pre>
 */
@RunWith(RobolectricTestRunner.class)
@Config(
        constants = BuildConfig.class,
        packageName = BuildConfig.APPLICATION_ID,
        application = TestApplication.class,
        sdk = Build.VERSION_CODES.M
)
public abstract class RobolectricTemp extends TestTemp {

    protected static final String TEST_ASSERT_ROOT = "src/test/assets/";

    @Mock
    protected Context application = RuntimeEnvironment.application;

    @Override
    @Before
    public void setUp() throws Exception {
        super.setUp();
        commonData();
    }

    private void commonData() {
        // TODO: sinlov commonData can use at here
    }

    @Override
    @After
    public void tearDown() throws Exception {
        super.tearDown();
    }
}
