package com.app.hyperpay.temp

import com.oppwa.mobile.connect.provider.Connect
import java.io.Serializable

data class PaymentHelperModel(
    var checkout_id: String? = null,
    var payment_type: HashSet<String> = hashSetOf(),
    var shopper_url: String? = null,
    var provider_mode: Connect.ProviderMode = Connect.ProviderMode.TEST
): Serializable
