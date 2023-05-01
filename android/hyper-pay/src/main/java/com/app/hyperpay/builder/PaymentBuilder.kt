package com.app.hyperpay.builder

import android.content.Context
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity

interface PaymentBuilder {
    /**
     * Is a set of strings as "VISA", "MASTER", "DIRECTDEBIT_SEPA", etc...
     * @params paymentType
     * */
    fun paymentType(paymentType: HashSet<String>): PaymentBuilder

    /**
     * Is used to setting CHECKOUT_ID that getting back from
     * your Back-End as String
     * @params checkoutId
     * */
    fun checkoutId(checkoutId: String): PaymentBuilder

    /**
     * Is used to set APPLICATION_ID or BUNDLE_ID ONLY
     * @params shopperUrl
    * */
    fun shopperResultUrl(shopperUrl: String): PaymentBuilder

    /**
     * Is used to set APPLICATION_ID or BUNDLE_ID ONLY
     * @params shopperUrl
    * */
    fun testMode(testMode: Boolean): PaymentBuilder

    /**
     * Is the method used to run the SDK activity
     * view and dialog to choose and pay
     * @params shopperUrl
     * */
    fun build(context: Context): Intent
}