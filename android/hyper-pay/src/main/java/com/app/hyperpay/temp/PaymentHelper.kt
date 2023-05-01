package com.app.hyperpay.temp
import android.content.Context
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.FragmentActivity
import com.app.hyperpay.builder.OnGettingResultBack
import com.app.hyperpay.builder.OnPaymentResponseCallback
import com.app.hyperpay.builder.PaymentBuilder
import com.app.hyperpay.helper_model.PaymentErrorModel
import com.app.hyperpay.helper_model.PaymentResponse
import com.app.hyperpay.helper_model.PaymentSuccessModel
import com.app.hyperpay.utils.StartingActivityResult
import com.oppwa.mobile.connect.checkout.dialog.CheckoutActivity
import com.oppwa.mobile.connect.checkout.meta.CheckoutSettings
import com.oppwa.mobile.connect.exception.PaymentError
import com.oppwa.mobile.connect.provider.Connect
import com.oppwa.mobile.connect.provider.Transaction
import com.oppwa.mobile.connect.provider.TransactionType

class PaymentHelper: PaymentBuilder, OnGettingResultBack  {
    private constructor(paymentCallback: OnPaymentResponseCallback) {
        mPaymentModel = PaymentHelperModel()
        mPaymentResponse = paymentCallback
//        createStartingActivity(activity)
    }
    private constructor(fragment: FragmentActivity, paymentCallback: OnPaymentResponseCallback) {
        mContext = fragment
        mPaymentModel = PaymentHelperModel()
        mPaymentResponse = paymentCallback
        createStartingFragment(fragment)
    }

    private var mContext: Context? = null
    private var mPaymentModel: PaymentHelperModel? = null
    private var mStartPayment: StartingActivityResult? = null
    private var mPaymentResponse: OnPaymentResponseCallback? = null

    override fun paymentType(paymentType: HashSet<String>): PaymentBuilder {
        mPaymentModel?.payment_type = paymentType
        return this
    }

    override fun checkoutId(checkoutId: String): PaymentBuilder {
        mPaymentModel?.checkout_id = checkoutId
        return this
    }

    override fun shopperResultUrl(shopperUrl: String): PaymentBuilder {
        mPaymentModel?.shopper_url = shopperUrl
        return this
    }

    override fun testMode(testMode: Boolean): PaymentBuilder {
        mPaymentModel?.provider_mode = if (testMode) Connect.ProviderMode.TEST else Connect.ProviderMode.LIVE
        return this
    }

    override fun build(context: Context): Intent {
        val checkoutSettings = CheckoutSettings(mPaymentModel?.checkout_id ?: "", mPaymentModel?.payment_type, mPaymentModel?.provider_mode!!)
        checkoutSettings.shopperResultUrl = "${mPaymentModel?.shopper_url}://result"

        return checkoutSettings.createCheckoutActivityIntent(context)

//        mStartPayment?.launchResultActivity(intent)
    }

    private fun createStartingActivity(activity: AppCompatActivity) {
        mStartPayment = StartingActivityResult(
            this@PaymentHelper
        )
        mStartPayment?.initActivityResult(activity)
    }
    private fun createStartingFragment(fragment: FragmentActivity) {
        mStartPayment = StartingActivityResult(
            this@PaymentHelper
        )
        mStartPayment?.initFragmentResult(fragment)
    }

    companion object {
        fun Builder(paymentCallback: OnPaymentResponseCallback): PaymentHelper {
            return PaymentHelper(paymentCallback)
        }
        fun Builder(fragment: FragmentActivity, paymentCallback: OnPaymentResponseCallback): PaymentHelper {
            return PaymentHelper(fragment, paymentCallback)
        }
    }

    fun onActivityResult(request: Int, data: Intent?) {
        when(request) {
            CheckoutActivity.RESULT_OK -> {
                val transaction: Transaction? = data?.getParcelableExtra(CheckoutActivity.CHECKOUT_RESULT_TRANSACTION)
                val resourcePath: String? = data?.getStringExtra(CheckoutActivity.CHECKOUT_RESULT_RESOURCE_PATH)
                mPaymentResponse?.onPaymentResponseCallback(PaymentResponse.PaymentSuccess(
                    PaymentSuccessModel(
                        resourcePath,
                        if (transaction?.transactionType == TransactionType.SYNC) PaymentSuccessModel.EnumTransactionType.SYNC
                        else PaymentSuccessModel.EnumTransactionType.ASYNC,
                    ),
                    resourcePath
                ))
            }

            CheckoutActivity.RESULT_CANCELED -> {
                mPaymentResponse?.onPaymentResponseCallback(PaymentResponse.PaymentCanceled)
            }

            CheckoutActivity.RESULT_ERROR -> {
                val error: PaymentError? =
                    data?.getParcelableExtra(CheckoutActivity.CHECKOUT_RESULT_ERROR)
                mPaymentResponse?.onPaymentResponseCallback(PaymentResponse.PaymentFailed(
                    PaymentErrorModel(
                        error?.errorCode.toString(),
                        error?.errorInfo,
                        error?.errorMessage
                    )
                ))
            }
        }

    }

    override fun onGettingResult(request: Int, data: Intent?) {
    }
}