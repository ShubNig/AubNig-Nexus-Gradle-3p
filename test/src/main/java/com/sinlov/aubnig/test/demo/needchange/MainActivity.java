package com.sinlov.aubnig.test.demo.needchange;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.sinlov.aubnig.test.demo.ux.TempTestActivity;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

public class MainActivity extends TempTestActivity {

    @BindView(R.id.btn_main_module_init_check)
    Button btnMainModuleInitCheck;
    @BindView(R.id.btn_main_skip_to_module)
    Button btnMainSkipToModule;
    @BindView(R.id.btn_main_get_module_data)
    Button btnMainGetModuleData;
    @BindView(R.id.tv_main_result)
    TextView tvMainResult;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        ButterKnife.bind(this);
    }

    @Override
    protected void processLogic(Bundle savedInstanceState) {

    }

    @OnClick({R.id.btn_main_module_init_check, R.id.btn_main_skip_to_module, R.id.btn_main_get_module_data})
    public void onViewClicked(View view) {
        switch (view.getId()) {
            case R.id.btn_main_module_init_check:
                break;
            case R.id.btn_main_skip_to_module:
                break;
            case R.id.btn_main_get_module_data:
                break;
        }
    }
}
