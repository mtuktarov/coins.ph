#!groovy
import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule
import hudson.security.csrf.DefaultCrumbIssuer
import jenkins.model.Jenkins

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin")
instance.setSecurityRealm(hudsonRealm)

//we are using HudsonPrivateSecurityRealm class and createAccount function to initialize a user definition
//with username and password as admin


def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()

//initiating a new instance of FullControlOnceLoggedInAuthorizationStrategy class which will allow the user
//administrator permissions once he has succesfully logged in after authentication. Also disabling read permissions
//for unauthenticated users

Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class)

def j = Jenkins.instance
if(j.getCrumbIssuer() == null){
    j.setCrumbIssuer(new DefaultCrumbIssuer(true))
    j.save()
    println 'CSRF Protection configurtaion has changed. Enabled CSRF Protection.'
}
else {
    println 'Nothing changed. CSRF Protection already configured.'
}

//CSRF protection