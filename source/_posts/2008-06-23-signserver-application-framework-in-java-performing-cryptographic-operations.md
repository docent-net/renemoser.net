---
title: SignServer: Application framework in Java performing cryptographic operations
categories:
 - applications
tags:
 - java
 - networking
 - oss
 - security
---

>The SignServer [1] is an application framework performing cryptographic operations for other applications. It's intended to be used in environments where keys are supposed to be protected in hardware but there isn't possible to connect such hardware to existing enterprise applications or where the operations are considered extra sensitive so the hardware have to protected more carefully. Another usage is to provide a simplified method to provide signatures in different application managed from one location in the company.
>From version 3.0 there also exists a mail signer framework that can be used to perform cryptographic operation on emails.
>The SignServer have a ready to use:
>
> * TimeStamp Authority (RFC 3161 complaint)
> * PDF Signer
> * MRTD Signer
> * Validation Service Framework
> * Group Key Service Framework
> * Simple Mail Signer
>
>The SignServer have been designed for high-availability and can be clustered for maximum reliability.
>
>Different kinds of sign tokens exist:
>
> * Soft token using PKCS12 files.
> * PKCS#11 HSM tokens, such as the Utimaco CryptoServer or nCipher nShield.
>* PrimeCardHSM using smart cards.

[1] <a href="http://www.signserver.org/">http://www.signserver.org/</a>
