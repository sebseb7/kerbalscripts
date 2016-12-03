declare parameter alt.

// set celestial body properties
// ease future parametrisation
set b to body:name.
set mu to 0.
if b = "Kerbin" {
    set mu to 3.5316000*10^12.  // gravitational parameter, mu = G mass
    set rb to 600000.           // radius of body [m]
    set soi to 84159286.        // sphere of influence [m]
    set ad0 to 1.2230948554874. // atmospheric density at msl [kg/m^3]
    set sh to 5000.             // scale height (atmosphere) [m]
    set ha to 69077.            // atmospheric height [m]
    set lorb to 80000.          // low orbit altitude [m]
}
if b = "Mun" {
    set mu to 6.5138398*10^10.
    set rb to 200000.
    set soi to 2429559.
    set ad0 to 0.
    set lorb to 14000. 
}
if b = "Minmus" {
    set mu to 1.7658000*10^9.
    set rb to 60000.
    set soi to 2247428.
    set ad0 to 0.
    set lorb to 10000. 
}
if mu = 0 {
    print "T+" + round(missiontime) + " WARNING: no body properties for " + b + "!".
}
if mu > 0 {
    print "T+" + round(missiontime) + " Loaded body properties for " + b.
}
set euler to 2.718281828.
set pi to 3.1415926535.




// create apoapsis maneuver node
print "T+" + round(missiontime) + " Apoapsis maneuver, orbiting " + body:name.
print "T+" + round(missiontime) + " Apoapsis: " + round(apoapsis/1000) + "km".
print "T+" + round(missiontime) + " Periapsis: " + round(periapsis/1000) + "km -> " + round(alt/1000) + "km".
// present orbit properties
set vom to velocity:orbit:mag.  // actual velocity
set r to rb + altitude.         // actual distance to body
set ra to rb + apoapsis.        // radius in apoapsis
set va to sqrt( vom^2 + 2*mu*(1/ra - 1/r) ). // velocity in apoapsis
set a to (periapsis + 2*rb + apoapsis)/2. // semi major axis present orbit
// future orbit properties
set r2 to rb + apoapsis.    // distance after burn at apoapsis
set a2 to (alt + 2*rb + apoapsis)/2. // semi major axis target orbit
set v2 to sqrt( vom^2 + (mu * (2/r2 - 2/r + 1/a - 1/a2 ) ) ).
// setup node 
set deltav to v2 - va.
print "T+" + round(missiontime) + " Apoapsis burn: " + round(va) + ", dv:" + round(deltav) + " -> " + round(v2) + "m/s".
set nd to node(time:seconds + eta:apoapsis, 0, 0, deltav).
add nd.
print "T+" + round(missiontime) + " Node created.".

