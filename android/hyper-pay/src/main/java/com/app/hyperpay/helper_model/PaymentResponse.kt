package com.app.hyperpay.helper_model

sealed class PaymentResponse {
    data class PaymentSuccess(val transaction: PaymentSuccessModel?, val resourcePath: String?): PaymentResponse()
    data class PaymentFailed(val paymentError: PaymentErrorModel?): PaymentResponse()
    object PaymentCanceled: PaymentResponse()
}