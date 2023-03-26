function br_core.get_full_frame(flags)
    flags = flags or {}
    local pw = flags.width or (8/16) -- width
    local pl = flags.length or (8/16) -- length
    local ph = flags.thickness or (2/16) -- height
    local ff = 0.5
    return -- connected
    {
        type = "connected",
        connect_top = (flags.notop and {}) or {
            {
                -pl, ff-ph, -pl,
                 pl, ff,     pl
            },
        },
        connect_bottom = (flags.nobottom and {}) or {
            {
                -pl, -ff,   -pl,
                 pl, -ff+ph, pl
            },
        },
        connect_front = (flags.nofront and {}) or {
            {
                -pw, -pl, -ff,
                 pw,  pl, -ff+ph
            }, flags.inner and {
                -ph, -ff, -ff,
                 ph,  ff,  ff
            }
        },
        connect_left = (flags.noleft and {}) or {
            {
                -ff,   -pl, -pw,
                -ff+ph, pl,  pw
            }, flags.inner and {
                -ff, -ff, -ph,
                 ff,  ff,  ph
            }
        },
        connect_back = (flags.noback and {}) or {
            {
                -pw, -pl, ff-ph,
                 pw,  pl, ff
            }, flags.inner and {
                -ph, -ff, -ff,
                 ph,  ff,  ff
            }
        },
        connect_right = (flags.noright and {}) or {
            {
                ff-ph, -pl, -pw,
                   ff,  pl,  pw
            }, flags.inner and {
                -ff, -ff, -ph,
                 ff,  ff,  ph
            }
        },
    }
end
