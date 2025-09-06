/********************************************************
 * Parametric 1S LiPo Battery Tray - vsergeev
 * https://github.com/vsergeev/3d-1s-lipo-battery-tray
 * CC-BY-4.0
 *
 * Release Notes
 *  * v1.0 - 09/06/2025
 *      * Initial release.
 ********************************************************/

/* [General] */

tray_rows = 5;
tray_columns = 5;
tray_battery_type = "standard"; // [standard, narrow]
tray_z_height = 15;

/* [Battery Slot] */

battery_slot_standard_dimensions = [15.6, 7.1];
battery_slot_standard_pitch = [20, 12];
battery_slot_narrow_dimensions = [11.9, 6.4];
battery_slot_narrow_pitch = [16, 12];
battery_slot_xy_radius = 1;

/* [Miscellaneous] */

tray_base_z_height = 2;
tray_xy_margin = 2.5;
tray_xy_radius = 5;
tray_xyz_chamfer = 2.5;

/* [Hidden] */

overlap_epsilon = 0.01;

$fn = 100;

/******************************************************************************/
/* Derived Parameters */
/******************************************************************************/

battery_slot_dimensions = tray_battery_type == "standard" ? battery_slot_standard_dimensions : battery_slot_narrow_dimensions;
battery_slot_pitch = tray_battery_type == "standard" ? battery_slot_standard_pitch : battery_slot_narrow_pitch;

tray_dimensions = [tray_columns * battery_slot_pitch.x + tray_xy_margin * 2, tray_rows * battery_slot_pitch.y + tray_xy_margin * 2];

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module battery_slot_profile() {
    offset(r=battery_slot_xy_radius)
        offset(delta=-battery_slot_xy_radius)
            square(battery_slot_dimensions, center=true);
}

module tray_base_profile() {
    offset(r=tray_xy_radius)
        offset(delta=-tray_xy_radius)
            square(tray_dimensions, center=true);
}

module tray_slot_profile() {
    translate([-(tray_columns - 1) * battery_slot_pitch.x / 2, -(tray_rows - 1) * battery_slot_pitch.y / 2]) {
        for (row = [0 : tray_rows - 1]) {
            for (col = [0 : tray_columns - 1]) {
                translate([col * battery_slot_pitch.x, row * battery_slot_pitch.y])
                    battery_slot_profile();
            }
        }
    }
}

/******************************************************************************/
/* Helper */
/******************************************************************************/

/* Simple 45 degree outer chamfer on a profile */
module chamfer(profile_width, profile_height, depth) {
    scale_factor = [(profile_width - 2 * depth) / profile_width, (profile_height - 2 * depth) / profile_height];

    difference() {
        translate([0, 0, -overlap_epsilon])
            linear_extrude(height=depth + overlap_epsilon, convexity=2)
                offset(delta=overlap_epsilon)
                    children();

         translate([0, 0, depth / 2])
            rotate([180, 0, 0])
                linear_extrude(height=depth + 3 * overlap_epsilon, scale=scale_factor, center=true, convexity=2)
                    children();
    }
}

/******************************************************************************/
/* 3D Extrusions */
/******************************************************************************/

module tray() {
    difference() {
        union() {
            /* Base */
            linear_extrude(tray_base_z_height)
                tray_base_profile();

            /* Slots */
            translate([0, 0, tray_base_z_height - overlap_epsilon]) {
                linear_extrude(tray_z_height - tray_base_z_height + overlap_epsilon, convexity=5) {
                    difference () {
                        tray_base_profile();
                        tray_slot_profile();
                    }
                }
            }
        }

        /* Bottom Chamfer */
        chamfer(tray_dimensions.x, tray_dimensions.y, tray_xyz_chamfer)
            tray_base_profile();

        /* Top Chamfer */
        translate([0, 0, tray_z_height])
            rotate([180, 0, 0])
                chamfer(tray_dimensions.x, tray_dimensions.y, tray_xyz_chamfer + overlap_epsilon)
                    tray_base_profile();
    }
}

/******************************************************************************/
/* Top Level */
/******************************************************************************/

tray();
