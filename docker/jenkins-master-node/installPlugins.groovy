#!groovy
import hudson.model.*
import hudson.remoting.Future
import jenkins.model.*
import java.util.concurrent.TimeUnit

{ String msg = getClass().protectionDomain.codeSource.location.path ->
    println "--> ${msg}"

    Jenkins.instance.getPluginManager().getPlugins()
    Jenkins.instance.getUpdateCenter().updateAllSites()

    def Map<String,Future<UpdateCenter.UpdateCenterJob>> updateCenterJobs = [:]
    def plugins = []
    new File('/usr/share/jenkins/ref/init.groovy.d/plugins.txt').eachLine { line ->
        plugins << line
    }
    plugins.each { pluginId ->
        try {
            def plugin = Jenkins.instance.getUpdateCenter().getPlugin(pluginId)
            if (!plugin.installed || (!plugin.installed.isPinned() && plugin.installed.hasUpdate())) {
                updateCenterJobs[pluginId] = plugin.deploy(true)
            }
        } catch (Exception x) {
            x.printStackTrace()
        }
    }

    updateCenterJobs.each { entry ->
        entry.getValue().get(5, TimeUnit.MINUTES)
    }

    if (updateCenterJobs.size() > 0) {
        Jenkins.instance.safeRestart()
    }

    println "--> ${msg} ... done"
} ()
