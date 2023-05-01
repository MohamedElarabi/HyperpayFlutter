package com.app.hyperpay.builder

import com.app.hyperpay.helper_model.PaymentResponse

interface OnPaymentResponseCallback {
    fun onPaymentResponseCallback(paymentResponse: PaymentResponse)
}