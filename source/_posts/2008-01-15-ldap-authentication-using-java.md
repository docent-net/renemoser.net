---
title : LDAP Authentication using Java
categories:
 - programming
tags :
 - java
 - ldap
---
~~~java
import javax.naming.*;
import javax.naming.directory.*;
import java.util.Hashtable;

/**
 * Demonstrates how to create an initial context to an LDAP server
 * using simple authentication.
 */

class Simple {
    public static void main(String[] args) {
        Hashtable authEnv = new Hashtable(11);
        String userName = "johnlennon";
        String passWord = "sushi974";
        String base = "ou=People,dc=example,dc=com";
        String dn = "uid=" + userName + "," + base;
        String ldapURL = "ldap://ldap.example.com:389";

        authEnv.put(Context.INITIAL_CONTEXT_FACTORY,"com.sun.jndi.ldap.LdapCtxFactory");
           authEnv.put(Context.PROVIDER_URL, ldapURL);
           authEnv.put(Context.SECURITY_AUTHENTICATION, "simple");
           authEnv.put(Context.SECURITY_PRINCIPAL, dn);
           authEnv.put(Context.SECURITY_CREDENTIALS, passWord);

        try {
            DirContext authContext = new InitialDirContext(authEnv);
            System.out.println("Authentication Success!");
        } catch (AuthenticationException authEx) {
            System.out.println("Authentication failed!");
        } catch (NamingException namEx) {
            System.out.println("Something went wrong!");
            namEx.printStackTrace();
        }
    }
}
~~~
