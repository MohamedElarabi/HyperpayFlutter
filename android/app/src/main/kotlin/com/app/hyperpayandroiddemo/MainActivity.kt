package com.app.hyperpayandroiddemo
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import androidx.appcompat.app.AppCompatActivity
import com.app.hyperpay.builder.OnPaymentResponseCallback
import com.app.hyperpay.helper_model.PaymentResponse
import com.app.hyperpay.temp.PaymentHelper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity :   FlutterActivity(),   OnPaymentResponseCallback {
    private val payChannel = "hyperPay.dev/startPayment"
    var trans = ""
    var res: MethodChannel.Result? = null

   @Override
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, payChannel).setMethodCallHandler {
                call, result ->
            if (call.method.equals("createPayment")) {
                res = result;
                val amount: Double? = call.argument("amount")
                val orderId: String? = call.argument("orderId")
//
//                PaymentHelper.Builder(this)
//                startActivityForResult(mPayment
//                    .paymentType(hashSetOf("VISA"))
//                    .checkoutId("67ADED325FACB56C688A32F21F23B43E.uat01-vm-tx01")
//                    .shopperResultUrl("com.app.hyperpayandroiddemo")
//                    .testMode(true)
//                    .build(this), PAYMENT_TYPE)

                    PaymentHelper.Builder(this, this)
    .paymentType(hashSetOf("VISA", "MASTER"))
    .checkoutId("67ADED325FACB56C688A32F21F23B43E.uat01-vm-tx01")
    .shopperResultUrl("com.app.hyperpayandroiddemo")
    .testMode(true)
    .build()



            } else {
                result.notImplemented()
            }
        }
    }

    private val mPayment by lazy { PaymentHelper.Builder(this) }
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        startActivityForResult(mPayment
//            .paymentType(hashSetOf("VISA"))
//            .checkoutId("A7C2160D8A3A594DA920F0729C0C2FF3.uat01-vm-tx04")
//            .shopperResultUrl("com.app.hyperpayandroiddemo")
//            .testMode(true)
//            .build(this), PAYMENT_TYPE)
//        Log.e("REERERER", trans);
//
//
//
//    }

    companion object {
        const val PAYMENT_TYPE = 110
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        mPayment.onActivityResult(resultCode, data)
    }


    override fun onPaymentResponseCallback(paymentResponse: PaymentResponse) {
        when(paymentResponse) {
            is PaymentResponse.PaymentSuccess -> {
                Log.e("PaymentHelper", "onPaymentResponseCallback: >>> ${paymentResponse.resourcePath}")
            }
            is PaymentResponse.PaymentCanceled -> {
                Log.e("PaymentHelper", "onPaymentResponseCallback: >>> CANCELED")

            }
            is PaymentResponse.PaymentFailed -> {
                Log.e("PaymentHelper", "onPaymentResponseCallback: >>> ${paymentResponse.paymentError?.error_code}")
                Log.e("PaymentHelper", "onPaymentResponseCallback: >>> ${paymentResponse.paymentError?.error_info}")
                Log.e("PaymentHelper", "onPaymentResponseCallback: >>> ${paymentResponse.paymentError?.error_message}")

            }
        }
    }

}
