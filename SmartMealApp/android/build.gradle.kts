allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory = rootProject.layout.buildDirectory.dir("../../build").get()

subprojects {
    layout.buildDirectory = rootProject.layout.buildDirectory.dir(name).get()
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}