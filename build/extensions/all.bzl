"""
Module to expose all extensions via a `CFGS_ALL` variable.
"""

load("//extensions/contrib:cfg.bzl", CFGS_CONTRIB = "CFGS")
load("//extensions/noset:cfg.bzl", CFG_NOSET = "CFG")
load("//extensions/sslutils:cfg.bzl", CFG_SSLUTILS = "CFG")

CFGS_ALL = {
    "contrib": [CFGS_CONTRIB[pgext_name] for pgext_name in CFGS_CONTRIB],
    "noset": [CFG_NOSET],
    "sslutils": [CFG_SSLUTILS],
}
