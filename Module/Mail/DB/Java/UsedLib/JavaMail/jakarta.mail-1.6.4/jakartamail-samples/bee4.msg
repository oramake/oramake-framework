From notifications@github.com Thu May 11 14:34:21 2017
Received: from userv0021.oracle.com (/156.151.31.71)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 May 2017 12:00:49 -0700
Return-Path: <?g>
Received: from aserp2020.oracle.com (aserp2020.oracle.com [141.146.126.73])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v4BLYOp8021784
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <bill.shannon@oracle.com>; Thu, 11 May 2017 21:34:24 GMT
Received: from pps.filterd (aserp2020.oracle.com [127.0.0.1])
	by aserp2020.oracle.com (8.16.0.20/8.16.0.20) with SMTP id v4BLXc4t040099
	for <bill.shannon@oracle.com>; Thu, 11 May 2017 21:34:24 GMT
Authentication-Results: oracle.com;
	spf=pass smtp.mailfrom=bs00011+caf_=bill.shannon=oracle.com@gmail.com
Received: from mail-ua0-f175.google.com (mail-ua0-f175.google.com [209.85.217.175])
	by aserp2020.oracle.com with ESMTP id 2acsvq9mht-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <bill.shannon@oracle.com>; Thu, 11 May 2017 21:34:23 +0000
Received: by mail-ua0-f175.google.com with SMTP id j17so36805776uag.3
        for <bill.shannon@oracle.com>; Thu, 11 May 2017 14:34:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:delivered-to:date:dkim-signature:from:reply-to
         :to:cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:precedence:list-id:list-archive:list-post
         :list-unsubscribe;
        bh=Bkc3eNO1lDhE4Vfn7CCbBIxvhS5H4pH3UuR+JMjgNCM=;
        b=KIo95Y0lj8Xe/Wgo4ZiF5TZR1wMqdFVcbwhaisXpIfVnaziGjjYJU9zGmgRebhJbZQ
         CdUg2EvurAb3QLoiLqIE38MSziJt8dEA4gXUg5RTqTua+zFeaP9HJFLiKRtKZM0J+M9A
         hLH5ecEaeNtJtXP61u4QEKqk8NkEEomruh3iaUQx7R3XOrJpfhjShvcg0lP3IRKYVU1B
         sJKUwPunRcAKy9zeQUPhq01KmuqpIelyoMMZPM6s8qF+eUbKIVh+oTb7h9QhdGyMFLx0
         09CUBsI2IW3sduCy02mvbV4uE5vW6tLucUuuz8wQpgwHOYnMC3ApkMR+Hl9ZA/yqcI6V
         JiNA==
X-Gm-Message-State: AODbwcDlUyjjVnP4SehlPc/QTvYse45trU2Ti3Z8skkqpGQ1rKEwVfDE
	0r0kl+rT3aYkc1iU8OjLRGhf4hYngp4NhfEPjP7uSQ==
X-Received: by 10.176.86.28 with SMTP id y28mr286443uaa.145.1494538462169;
        Thu, 11 May 2017 14:34:22 -0700 (PDT)
X-Forwarded-To: bill.shannon@oracle.com
X-Forwarded-For: bs00011@gmail.com bill.shannon@oracle.com
Delivered-To: bs00011@gmail.com
Received: by 10.103.30.130 with SMTP id e124csp38674vse;
        Thu, 11 May 2017 14:34:21 -0700 (PDT)
X-Received: by 10.55.93.69 with SMTP id r66mr671421qkb.14.1494538461414;
        Thu, 11 May 2017 14:34:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1494538461; cv=none;
        d=google.com; s=arc-20160816;
        b=yNHNvBOUB1edVPAK+9SSdLRgXELSB+F7Ocq4OauZtlpSRhXaIpCxK0nHSQ5B9IrEe8
         5C7gpK402x39IPb44qVruUuaxs0IdnAKYHP8v6MfYx/PDDBTdVXWpcFBglIUhG3HnVOp
         vEttGXjlVk22OmQi4TtVN7g4nG7BpJhfP4ZwmNf/SHyOGxmLVmjE9bNCvZspereYfTHX
         yBOM+OMQJGPYKpLgyIbKmTffz/HBdRNHSr/lYx8Xq2VJwM7C2I78OZMIVSLnzuSsjMq6
         yBbDB1h+l0wQJsSjDGZHofSAAsMv37seVhHM/it8LkqNIJ9IYLqeaWJVpbHK2On0cOIV
         spyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=list-unsubscribe:list-post:list-archive:list-id:precedence
         :content-transfer-encoding:mime-version:subject:references
         :in-reply-to:message-id:cc:to:reply-to:from:dkim-signature:date
         :arc-authentication-results;
        bh=Bkc3eNO1lDhE4Vfn7CCbBIxvhS5H4pH3UuR+JMjgNCM=;
        b=ANEtW9gfoTy0G3js598BL0K7G0i9BIjocYBmknKh7TaGiH+FEAO+Ok4sHEzZ9DPPrK
         mo0IM7LumTmL7qpaBWgVKOqeVEYRoYdHnQhVPLX1A/WJiSygdZ+VY9QCPvIf9oDLyO2/
         mc1HVcGIwXyPCbsrA08esDttTmoIyHzycIzPB3h0Q2D9L1A0suA47TirtA/whnkKlvMl
         ZQv7g6OwYVHh0Z4+zE3yicm1o1M8dXjr8VnU1rYdJ23AFEhJ8Jno+N9DoJRDC8rxaAxW
         n0Y+xg9Z2wuGjfyg31QmSe5sSZ5slPqSAi5YfcXugKSsFedgbXdKXgiTl7NCrECMVdib
         Mz8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass (test mode) header.i=@github.com;
       spf=pass (google.com: domain of noreply@github.com designates 192.30.252.198 as permitted sender) smtp.mailfrom=noreply@github.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=github.com
Received: from github-smtp2a-ext-cp1-prd.iad.github.net (github-smtp2-ext7.iad.github.net. [192.30.252.198])
        by mx.google.com with ESMTPS id m131si1229451qke.65.2017.05.11.14.34.21
        for <bs00011@gmail.com>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 14:34:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of noreply@github.com designates 192.30.252.198 as permitted sender) client-ip=192.30.252.198;
Authentication-Results: mx.google.com;
       dkim=pass (test mode) header.i=@github.com;
       spf=pass (google.com: domain of noreply@github.com designates 192.30.252.198 as permitted sender) smtp.mailfrom=noreply@github.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=github.com
Date: Thu, 11 May 2017 14:34:21 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=github.com;
	s=pf2014; t=1494538461;
	bh=Bkc3eNO1lDhE4Vfn7CCbBIxvhS5H4pH3UuR+JMjgNCM=;
	h=From:Reply-To:To:Cc:In-Reply-To:References:Subject:List-ID:
	 List-Archive:List-Post:List-Unsubscribe:From;
	b=P3pdgRAk3GFVvm+4s+tmxfr/jXWmqM87BCyu+QLmGU7ORd/0nXFitbcH7trv1Np3O
	 oD1u/lAbQ+RTJOoTpAmZbjuYIE5PA0kKRxbTlvmDDQGO1MeJurettZhpbqu76mF9b3
	 JXwZwpiAALYxM6julNBwRs9FfqKiCPPaqkPBMk6A=
From: glassfishrobot <notifications@github.com>
Reply-To: javaee/glassfish <reply+00028ba313a43d8ece671878e191660842eef90d325014c492cf00000001152c9add92a169ce0d9397e8@reply.github.com>
To: javaee/glassfish <glassfish@noreply.github.com>
Cc: Subscribed <subscribed@noreply.github.com>
Message-ID: <javaee/glassfish/pull/21749/c300923439@github.com>
In-Reply-To: <javaee/glassfish/pull/21749@github.com>
References: <javaee/glassfish/pull/21749@github.com>
Subject: Re: [javaee/glassfish] Integrate Grizzly 2.4.0-beta2 (#21749)
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="--==_mimepart_5914d8dd12806_69a33ffc7cbd9c38578e8";
 charset=UTF-8
Precedence: list
X-GitHub-Sender: glassfishrobot
X-GitHub-Recipient: bshannon
X-GitHub-Reason: subscribed
List-ID: javaee/glassfish <glassfish.javaee.github.com>
List-Archive: https://github.com/javaee/glassfish
List-Post: <mailto:reply+00028ba313a43d8ece671878e191660842eef90d325014c492cf00000001152c9add92a169ce0d9397e8@reply.github.com>
List-Unsubscribe: <mailto:unsub+00028ba313a43d8ece671878e191660842eef90d325014c492cf00000001152c9add92a169ce0d9397e8@reply.github.com>,
 <https://github.com/notifications/unsubscribe/AAKLox1BNm17-foiNrGhHMxHbEicJ70pks5r437dgaJpZM4NXE8s>
X-Auto-Response-Suppress: All
X-GitHub-Recipient-Address: bs00011@gmail.com
X-PDR: PASS
X-Source-IP: 209.85.217.175
X-ServerName: mail-ua0-f175.google.com
X-Proofpoint-SPF-Result: pass
X-Proofpoint-SPF-Record: v=spf1 redirect=_spf.google.com
X-Proofpoint-Virus-Version: vendor=nai engine=5800 definitions=8525 signatures=668453
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 spamscore=0 suspectscore=1
 malwarescore=0 phishscore=0 adultscore=0 bulkscore=8 classifier=spam
 adjust=0 reason=mlx scancount=1 engine=8.0.1-1703280000
 definitions=main-1705110125
X-Spam: Clean
Content-Length: 55


----==_mimepart_5914d8dd12806_69a33ffc7cbd9c38578e8--

