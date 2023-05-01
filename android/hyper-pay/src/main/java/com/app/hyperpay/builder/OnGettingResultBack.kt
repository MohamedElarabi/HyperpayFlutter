package com.app.hyperpay.builder
import android.content.Intent
import com.app.hyperpay.helper_model.PaymentResponse

interface OnGettingResultBack {
    fun onGettingResult(request: Int, data: Intent?)
}