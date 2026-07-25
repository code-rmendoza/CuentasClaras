allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
    val configureNamespace = Action<Project> {
        if (plugins.hasPlugin("com.android.library")) {
            val android = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
            if (android != null) {
                android.compileSdk = 35
                if (android.namespace == null) {
                    if (name == "blue_thermal_printer") {
                        android.namespace = "id.kakzaki.blue_thermal_printer"
                    } else {
                        android.namespace = "id.flutter.plugins.${name.replace("-", "_")}"
                    }
                }
            }
        }
    }
    if (state.executed) {
        configureNamespace.execute(this)
    } else {
        afterEvaluate(configureNamespace)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
