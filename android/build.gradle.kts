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
}

// Some Isar native-lib packages ship without an Android `namespace`, which
// Android Gradle Plugin 8+ requires. Inject one (derived from the module name)
// only if it's missing, for any isar* library module. Uses a `plugins.withId`
// hook (not `afterEvaluate`, which clashes with the template's
// `evaluationDependsOn(":app")`) and withGroovyBuilder to avoid referencing AGP
// types on the root classpath. This is a harmless no-op when the package
// already declares a namespace (e.g. isar_community 3.3.x).
subprojects {
    if (project.name.startsWith("isar")) {
        plugins.withId("com.android.library") {
            extensions.findByName("android")?.withGroovyBuilder {
                if (getProperty("namespace") == null) {
                    setProperty("namespace", "dev.isar.${project.name}")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
