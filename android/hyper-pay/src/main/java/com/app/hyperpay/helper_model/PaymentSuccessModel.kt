package com.app.hyperpay.helper_model

import java.io.Serializable

data class PaymentSuccessModel(
    val resourcePath: String?,
    val transaction_type: EnumTransactionType
): Serializable {
    enum class EnumTransactionType {
        SYNC,
        ASYNC
    }
}
