/* ============================================================
   gta4inver v2 - detailed item artwork (SVG, hand-drawn vector)
   Each item is a small illustration: gradients, shading, specular
   highlights and a soft contact shadow, so thumbnails read as
   realistic props instead of flat glyphs.
   ============================================================ */

window.LUX_ICONS = {

    /* ---------------------------------------------------------- burger */
    burger: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="bgr-bunTop" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#f8d79c"/><stop offset=".45" stop-color="#e2ab5d"/>
                <stop offset="1" stop-color="#b57a30"/>
            </linearGradient>
            <linearGradient id="bgr-bunBot" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#e6b169"/><stop offset="1" stop-color="#a86f2a"/>
            </linearGradient>
            <linearGradient id="bgr-patty" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#6d3a22"/><stop offset=".5" stop-color="#4d2513"/>
                <stop offset="1" stop-color="#331509"/>
            </linearGradient>
            <linearGradient id="bgr-cheese" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#ffd85e"/><stop offset="1" stop-color="#e2a318"/>
            </linearGradient>
            <linearGradient id="bgr-let" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#8ccf4f"/><stop offset="1" stop-color="#4c8a24"/>
            </linearGradient>
        </defs>
        <ellipse cx="24" cy="43" rx="17" ry="2.6" fill="#000" opacity=".35"/>
        <path d="M5 23c0-11 38-11 38 0z" fill="url(#bgr-bunTop)" stroke="#7a4a18" stroke-width=".7"/>
        <path d="M8 21c2-6 30-7 32-1" fill="none" stroke="#fff" stroke-opacity=".55" stroke-width="1.6" stroke-linecap="round"/>
        <g fill="#fdf0cf" opacity=".95">
            <ellipse cx="15" cy="17" rx="1.8" ry="1.1" transform="rotate(-18 15 17)"/>
            <ellipse cx="23" cy="14" rx="1.9" ry="1.1" transform="rotate(6 23 14)"/>
            <ellipse cx="31" cy="16.5" rx="1.8" ry="1.1" transform="rotate(20 31 16.5)"/>
            <ellipse cx="19" cy="20" rx="1.6" ry="1" transform="rotate(-8 19 20)"/>
            <ellipse cx="28" cy="20" rx="1.6" ry="1" transform="rotate(12 28 20)"/>
        </g>
        <path d="M5 23h38c-1 3-3.2 4.2-6.2 4.2-2 0-3-1.6-4.8-1.6s-2.8 2-4.8 2-3-2-4.9-2-3 1.6-4.9 1.6S14.4 25.6 12.4 25.6C8.6 25.6 6 24.8 5 23z" fill="url(#bgr-let)"/>
        <path d="M6 26.4h36v2.6a2 2 0 0 1-2 2h-1.6l-1 3-1.6-3h-5.4l-1 3-1.6-3h-4.6l-1 3-1.6-3H15l-1 3-1.6-3H8a2 2 0 0 1-2-2z" fill="url(#bgr-cheese)" stroke="#b57f11" stroke-width=".6"/>
        <rect x="6" y="29.6" width="36" height="6.2" rx="3.1" fill="url(#bgr-patty)"/>
        <g fill="#8a5230" opacity=".55">
            <circle cx="14" cy="32" r=".9"/><circle cx="21" cy="33.4" r=".8"/>
            <circle cx="29" cy="32.2" r=".9"/><circle cx="35" cy="33.6" r=".7"/>
        </g>
        <path d="M6 35.6h36c0 4.4-3.2 6.6-7.4 6.6H13.4C9.2 42.2 6 40 6 35.6z" fill="url(#bgr-bunBot)" stroke="#7a4a18" stroke-width=".7"/>
        <path d="M10 37.4h28" stroke="#fff" stroke-opacity=".28" stroke-width="1.4" stroke-linecap="round"/>
    </svg>`,

    /* ---------------------------------------------------------- pizza */
    pizza: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="pz-cheese" x1=".2" y1="0" x2=".8" y2="1">
                <stop offset="0" stop-color="#ffd97a"/><stop offset=".55" stop-color="#f0b93f"/>
                <stop offset="1" stop-color="#c98f1e"/>
            </linearGradient>
            <linearGradient id="pz-crust" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#e6b070"/><stop offset="1" stop-color="#b1783a"/>
            </linearGradient>
            <radialGradient id="pz-pep" cx=".35" cy=".3" r=".8">
                <stop offset="0" stop-color="#c8493a"/><stop offset="1" stop-color="#8c2018"/>
            </radialGradient>
        </defs>
        <ellipse cx="24" cy="44" rx="14" ry="2.4" fill="#000" opacity=".3"/>
        <path d="M24 44 8.6 15.4C17.7 8.9 30.3 8.9 39.4 15.4z" fill="url(#pz-cheese)" stroke="#a8710f" stroke-width=".7"/>
        <path d="M24 44 8.6 15.4c3.1-2.2 6.4-3.7 9.9-4.6z" fill="#fff" opacity=".07"/>
        <path d="M8.6 15.4C17.7 8.9 30.3 8.9 39.4 15.4l-2.6 4.8c-8-4.9-18.2-4.9-26.2 0z" fill="url(#pz-crust)" stroke="#8a5a26" stroke-width=".7"/>
        <path d="M10.2 14.6c7.9-4.4 19.7-4.4 27.6 0" fill="none" stroke="#7c4d1d" stroke-opacity=".5" stroke-width="1"/>
        <g fill="url(#pz-pep)" stroke="#5e120c" stroke-width=".5">
            <circle cx="20" cy="24" r="3.2"/><circle cx="29" cy="26.5" r="2.9"/>
            <circle cx="24" cy="34" r="2.7"/><circle cx="16" cy="20" r="2.2"/>
            <circle cx="33" cy="19.5" r="2.1"/>
        </g>
        <g fill="#8fbf4a" opacity=".9">
            <ellipse cx="25.5" cy="21" rx="1.2" ry=".7" transform="rotate(-30 25.5 21)"/>
            <ellipse cx="19" cy="30" rx="1.1" ry=".65" transform="rotate(20 19 30)"/>
            <ellipse cx="30" cy="32.5" rx="1.1" ry=".65" transform="rotate(-15 30 32.5)"/>
        </g>
        <path d="M24 44 33 26" stroke="#b57f11" stroke-opacity=".35" stroke-width=".9"/>
    </svg>`,

    /* ---------------------------------------------------------- water */
    water: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="wt-bottle" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0" stop-color="#d8f1fb" stop-opacity=".95"/>
                <stop offset=".28" stop-color="#a9d9ef"/><stop offset=".62" stop-color="#7cbcd8"/>
                <stop offset="1" stop-color="#5d9cba"/>
            </linearGradient>
            <linearGradient id="wt-cap" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0" stop-color="#5cb6e8"/><stop offset=".5" stop-color="#2b7fb8"/>
                <stop offset="1" stop-color="#1b5c8a"/>
            </linearGradient>
            <linearGradient id="wt-label" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#ffffff"/><stop offset="1" stop-color="#dbe3ea"/>
            </linearGradient>
        </defs>
        <ellipse cx="24" cy="44" rx="9" ry="2.2" fill="#000" opacity=".3"/>
        <rect x="19" y="4" width="10" height="6" rx="1.4" fill="url(#wt-cap)"/>
        <rect x="19" y="4" width="10" height="2" rx="1" fill="#fff" opacity=".35"/>
        <rect x="20.5" y="8.6" width="7" height="3.4" fill="#8fb6c9"/>
        <path d="M18 11.8h12c3.6 0 6.4 3 6.4 6.6v19a4.6 4.6 0 0 1-4.6 4.6H16.2A4.6 4.6 0 0 1 11.6 37V18.4c0-3.6 2.8-6.6 6.4-6.6z" fill="url(#wt-bottle)" stroke="#3f7d9c" stroke-width=".7"/>
        <path d="M15 16.5v20.2c0 1.6 1 2.7 2.4 2.7" fill="none" stroke="#fff" stroke-opacity=".75" stroke-width="2" stroke-linecap="round"/>
        <rect x="11.6" y="22" width="24.8" height="11" fill="url(#wt-label)" opacity=".96"/>
        <rect x="11.6" y="22" width="24.8" height="11" fill="none" stroke="#b9c4cf" stroke-width=".5"/>
        <rect x="11.6" y="26.4" width="24.8" height="2.2" fill="#2b7fb8" opacity=".85"/>
        <text x="24" y="25.6" font-family="Segoe UI, Arial" font-size="4.2" font-weight="800" fill="#2b7fb8" text-anchor="middle" letter-spacing=".5">AQUA</text>
        <text x="24" y="32.4" font-family="Segoe UI, Arial" font-size="3.1" fill="#6b7684" text-anchor="middle">500 ml</text>
        <path d="M31.6 13.4c1.8 1.3 2.6 3.2 2.6 5.4v18" fill="none" stroke="#fff" stroke-opacity=".4" stroke-width="1.6" stroke-linecap="round"/>
    </svg>`,

    /* ---------------------------------------------------------- soda */
    soda: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="sd-can" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0" stop-color="#f0574a"/><stop offset=".22" stop-color="#d02a22"/>
                <stop offset=".55" stop-color="#a8160f"/><stop offset=".82" stop-color="#c9241b"/>
                <stop offset="1" stop-color="#7d0d09"/>
            </linearGradient>
            <linearGradient id="sd-metal" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#eef2f6"/><stop offset=".5" stop-color="#b9c2cc"/>
                <stop offset="1" stop-color="#7d868f"/>
            </linearGradient>
        </defs>
        <ellipse cx="24" cy="44" rx="9" ry="2.2" fill="#000" opacity=".32"/>
        <path d="M14.6 9h18.8c1.8 0 3.2 1.1 3.2 2.6v25.8c0 2.4-2 4.4-4.4 4.4H15.8c-2.4 0-4.4-2-4.4-4.4V11.6C11.4 10.1 12.8 9 14.6 9z" fill="url(#sd-can)"/>
        <ellipse cx="24" cy="9" rx="9.4" ry="2.6" fill="url(#sd-metal)"/>
        <ellipse cx="24" cy="8.6" rx="6.4" ry="1.2" fill="#8e979f"/>
        <rect x="21.4" y="7.4" width="6" height="1.6" rx=".8" fill="#cfd6dd"/>
        <path d="M13 15.4h22v3.4H13z" fill="#fff" opacity=".16"/>
        <path d="M12 27.6c4-2.6 8-2.6 12 0s8 2.6 12 0v4.6c-4 2.6-8 2.6-12 0s-8-2.6-12 0z" fill="#fff" opacity=".9"/>
        <text x="24" y="24" font-family="Segoe UI, Arial" font-size="6.4" font-weight="800" fill="#fff" text-anchor="middle" letter-spacing="1">COLA</text>
        <path d="M14.4 12.4v24.2" stroke="#fff" stroke-opacity=".3" stroke-width="2" stroke-linecap="round"/>
        <path d="M33.6 12.4v22" stroke="#000" stroke-opacity=".18" stroke-width="2.4" stroke-linecap="round"/>
        <g fill="#fff" opacity=".28">
            <circle cx="17.6" cy="33.4" r=".7"/><circle cx="20.4" cy="35.6" r=".5"/>
            <circle cx="29.4" cy="34.4" r=".6"/><circle cx="31.6" cy="32.2" r=".45"/>
        </g>
    </svg>`,

    /* ---------------------------------------------------------- medkit */
    medkit: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="md-box" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#fdfefe"/><stop offset=".55" stop-color="#e3e8ee"/>
                <stop offset="1" stop-color="#b9c2cc"/>
            </linearGradient>
            <linearGradient id="md-cross" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#f0524b"/><stop offset="1" stop-color="#b0191c"/>
            </linearGradient>
            <linearGradient id="md-lid" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#cfd6de"/><stop offset="1" stop-color="#98a2ad"/>
            </linearGradient>
        </defs>
        <ellipse cx="24" cy="44.4" rx="15" ry="2.4" fill="#000" opacity=".32"/>
        <path d="M18 12.4V10c0-1 .8-1.8 1.8-1.8h8.4c1 0 1.8.8 1.8 1.8v2.4" fill="none" stroke="#8d97a2" stroke-width="2.6" stroke-linecap="round"/>
        <rect x="5.4" y="12.4" width="37.2" height="7.6" rx="2.2" fill="url(#md-lid)" stroke="#7c8792" stroke-width=".6"/>
        <rect x="5.4" y="12.4" width="37.2" height="2.4" rx="1.2" fill="#fff" opacity=".55"/>
        <rect x="6.6" y="19.4" width="34.8" height="23.6" rx="2.4" fill="url(#md-box)" stroke="#8b959f" stroke-width=".7"/>
        <rect x="6.6" y="19.4" width="34.8" height="4" fill="#000" opacity=".06"/>
        <path d="M21.4 23h5.2v4.6h4.6v5.2h-4.6v4.6h-5.2v-4.6h-4.6v-5.2h4.6z" fill="url(#md-cross)" stroke="#8e1214" stroke-width=".5"/>
        <rect x="21.4" y="23" width="5.2" height="1.6" fill="#fff" opacity=".3"/>
        <rect x="22.4" y="30.6" width="3.2" height="1.2" rx=".6" fill="#7a8088"/>
        <rect x="22.6" y="30.2" width="2.8" height="1.8" rx=".5" fill="#c9d0d8" stroke="#7a8088" stroke-width=".4"/>
        <path d="M10 21.6v19.8" stroke="#fff" stroke-opacity=".7" stroke-width="1.6" stroke-linecap="round"/>
    </svg>`,

    /* ---------------------------------------------------------- repair kit */
    repairkit: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="rk-body" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#e2564a"/><stop offset=".45" stop-color="#c0342b"/>
                <stop offset="1" stop-color="#7e1a15"/>
            </linearGradient>
            <linearGradient id="rk-lid" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#e8695c"/><stop offset="1" stop-color="#a52a22"/>
            </linearGradient>
            <linearGradient id="rk-metal" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#e6ebf0"/><stop offset=".5" stop-color="#9aa4ae"/>
                <stop offset="1" stop-color="#646d76"/>
            </linearGradient>
        </defs>
        <ellipse cx="24" cy="43.6" rx="15" ry="2.4" fill="#000" opacity=".33"/>
        <path d="M16.6 12.6V10a3 3 0 0 1 3-3h8.8a3 3 0 0 1 3 3v2.6" fill="none" stroke="url(#rk-metal)" stroke-width="3" stroke-linecap="round"/>
        <rect x="5" y="13.6" width="38" height="8.2" rx="2" fill="url(#rk-lid)" stroke="#5f1210" stroke-width=".7"/>
        <rect x="5" y="13.6" width="38" height="2.2" rx="1" fill="#fff" opacity=".32"/>
        <rect x="6.4" y="20.6" width="35.2" height="22.4" rx="2.2" fill="url(#rk-body)" stroke="#5f1210" stroke-width=".7"/>
        <rect x="6.4" y="20.6" width="35.2" height="3.4" fill="#000" opacity=".14"/>
        <rect x="6.4" y="20.6" width="35.2" height="22.4" rx="2.2" fill="none" stroke="#ff9a90" stroke-opacity=".28" stroke-width=".8"/>
        <rect x="20.6" y="19.4" width="6.8" height="6" rx="1.2" fill="url(#rk-metal)" stroke="#4e565f" stroke-width=".5"/>
        <rect x="22.2" y="21" width="3.6" height="2.8" rx=".6" fill="#3c434b"/>
        <g fill="#f0d9a0" opacity=".85">
            <circle cx="10.4" cy="24.4" r="1"/><circle cx="37.6" cy="24.4" r="1"/>
            <circle cx="10.4" cy="39.4" r="1"/><circle cx="37.6" cy="39.4" r="1"/>
        </g>
        <rect x="10" y="29" width="14" height="8.6" rx="1" fill="#fff" opacity=".12"/>
        <text x="27" y="35.4" font-family="Segoe UI, Arial" font-size="5.6" font-weight="800" fill="#ffe9c9" opacity=".9" text-anchor="middle">TOOLS</text>
        <path d="M8 22.6v18.6" stroke="#fff" stroke-opacity=".3" stroke-width="1.6" stroke-linecap="round"/>
    </svg>`,

    /* ---------------------------------------------------------- phone */
    phone: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="ph-body" x1=".1" y1="0" x2=".9" y2="1">
                <stop offset="0" stop-color="#4a525e"/><stop offset=".35" stop-color="#20252d"/>
                <stop offset="1" stop-color="#0b0e12"/>
            </linearGradient>
            <linearGradient id="ph-screen" x1="0" y1="0" x2=".7" y2="1">
                <stop offset="0" stop-color="#3a5f7d"/><stop offset=".45" stop-color="#20364a"/>
                <stop offset="1" stop-color="#0d1a24"/>
            </linearGradient>
            <linearGradient id="ph-gold" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0" stop-color="#f4dc94"/><stop offset=".5" stop-color="#d4af37"/>
                <stop offset="1" stop-color="#8f7420"/>
            </linearGradient>
        </defs>
        <ellipse cx="24" cy="45" rx="9.5" ry="2.2" fill="#000" opacity=".35"/>
        <rect x="12.4" y="3.6" width="23.2" height="40.8" rx="5.2" fill="url(#ph-gold)"/>
        <rect x="13.4" y="4.6" width="21.2" height="38.8" rx="4.4" fill="url(#ph-body)"/>
        <rect x="15.4" y="8" width="17.2" height="30" rx="2" fill="url(#ph-screen)"/>
        <rect x="15.4" y="8" width="17.2" height="30" rx="2" fill="none" stroke="#000" stroke-opacity=".35" stroke-width=".7"/>
        <path d="M15.4 8h17.2v9.4c-5.6 3.4-11.4 3.4-17.2 0z" fill="#fff" opacity=".07"/>
        <rect x="20.4" y="5.6" width="7.2" height="1.4" rx=".7" fill="#0a0c10"/>
        <circle cx="24" cy="6.3" r=".55" fill="#2f6f9a"/>
        <g fill="#fff" opacity=".85">
            <rect x="17.6" y="11" width="6" height="4.6" rx="1.1"/>
            <rect x="24.6" y="11" width="6" height="4.6" rx="1.1" opacity=".7"/>
            <rect x="17.6" y="17" width="6" height="4.6" rx="1.1" opacity=".55"/>
            <rect x="24.6" y="17" width="6" height="4.6" rx="1.1" opacity=".4"/>
        </g>
        <rect x="16.6" y="35.4" width="14.8" height="1.6" rx=".8" fill="#fff" opacity=".35"/>
        <circle cx="24" cy="39.6" r="1.5" fill="#1a2028" stroke="#6c7783" stroke-width=".6"/>
        <path d="M15.4 33.4h17.2" stroke="#000" stroke-opacity=".4" stroke-width=".8"/>
    </svg>`,

    /* ---------------------------------------------------------- id card */
    id_card: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="id-card" x1="0" y1="0" x2=".8" y2="1">
                <stop offset="0" stop-color="#ffffff"/><stop offset=".6" stop-color="#e8edf3"/>
                <stop offset="1" stop-color="#c2cbd5"/>
            </linearGradient>
            <linearGradient id="id-photo" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#8fa6bd"/><stop offset="1" stop-color="#5d7a95"/>
            </linearGradient>
            <linearGradient id="id-gold" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0" stop-color="#f6e4a8"/><stop offset=".55" stop-color="#d4af37"/>
                <stop offset="1" stop-color="#96781f"/>
            </linearGradient>
        </defs>
        <rect x="13.6" y="5.6" width="26.4" height="36.8" rx="3.2" fill="#0e1116" opacity=".35" transform="rotate(7 26.8 24)"/>
        <rect x="6.6" y="6.4" width="34.8" height="35.2" rx="3.2" fill="url(#id-card)" stroke="#9aa5b1" stroke-width=".7"/>
        <path d="M6.6 6.4h34.8v7.2H6.6z" fill="url(#id-gold)"/>
        <text x="24" y="11.6" font-family="Segoe UI, Arial" font-size="3.6" font-weight="800" fill="#231a05" text-anchor="middle" letter-spacing="1.4">LOS SANTOS</text>
        <rect x="10.4" y="17" width="12.6" height="15" rx="1.4" fill="url(#id-photo)"/>
        <circle cx="16.7" cy="22.4" r="3.1" fill="#dfe7ef"/>
        <path d="M11.4 32c0-3.1 2.4-5 5.3-5s5.3 1.9 5.3 5z" fill="#dfe7ef"/>
        <g fill="#5f6a76">
            <rect x="25.6" y="18" width="12.6" height="1.8" rx=".9"/>
            <rect x="25.6" y="21.6" width="9.4" height="1.6" rx=".8" opacity=".8"/>
            <rect x="25.6" y="24.8" width="11.4" height="1.6" rx=".8" opacity=".6"/>
            <rect x="25.6" y="28" width="7.6" height="1.6" rx=".8" opacity=".45"/>
        </g>
        <rect x="25.6" y="32.4" width="5.4" height="4.2" rx="1" fill="url(#id-gold)" stroke="#8a6e1c" stroke-width=".4"/>
        <rect x="27" y="33.8" width="2.6" height="1.4" fill="#8a6e1c" opacity=".7"/>
        <path d="M9.4 9.4h8" stroke="#fff" stroke-opacity=".6" stroke-width="1.6" stroke-linecap="round"/>
    </svg>`,

    /* ---------------------------------------------------------- radio */
    radio: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="rd-body" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#4b525c"/><stop offset=".4" stop-color="#2a2f37"/>
                <stop offset="1" stop-color="#121519"/>
            </linearGradient>
            <linearGradient id="rd-gold" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0" stop-color="#f2da90"/><stop offset=".5" stop-color="#d4af37"/>
                <stop offset="1" stop-color="#8f7420"/>
            </linearGradient>
        </defs>
        <ellipse cx="24" cy="44" rx="11" ry="2.3" fill="#000" opacity=".35"/>
        <rect x="31.4" y="4" width="2" height="12" rx="1" fill="#9aa4ae" transform="rotate(14 32.4 10)"/>
        <rect x="12.4" y="11.4" width="23.2" height="30.6" rx="3.2" fill="url(#rd-body)" stroke="#05070a" stroke-width=".8"/>
        <rect x="12.4" y="11.4" width="23.2" height="30.6" rx="3.2" fill="none" stroke="#7d8792" stroke-opacity=".35" stroke-width=".7"/>
        <rect x="15.4" y="14.4" width="17.2" height="11.4" rx="1.6" fill="#0a0d11" stroke="#38414c" stroke-width=".6"/>
        <g fill="#5d6b7a" opacity=".85">
            <circle cx="18" cy="17.4" r=".8"/><circle cx="21" cy="17.4" r=".8"/><circle cx="24" cy="17.4" r=".8"/>
            <circle cx="27" cy="17.4" r=".8"/><circle cx="30" cy="17.4" r=".8"/>
            <circle cx="18" cy="20.4" r=".8"/><circle cx="21" cy="20.4" r=".8"/><circle cx="24" cy="20.4" r=".8"/>
            <circle cx="27" cy="20.4" r=".8"/><circle cx="30" cy="20.4" r=".8"/>
            <circle cx="18" cy="23.4" r=".8"/><circle cx="21" cy="23.4" r=".8"/><circle cx="24" cy="23.4" r=".8"/>
            <circle cx="27" cy="23.4" r=".8"/><circle cx="30" cy="23.4" r=".8"/>
        </g>
        <circle cx="20" cy="32.6" r="3.9" fill="url(#rd-gold)" stroke="#7a6218" stroke-width=".6"/>
        <circle cx="20" cy="32.6" r="2.4" fill="#1a1f26"/>
        <path d="M20 31v2.2" stroke="#d4af37" stroke-width=".9" stroke-linecap="round"/>
        <circle cx="29.4" cy="30.4" r="1.5" fill="#5fc06e"/>
        <circle cx="29.4" cy="30.4" r="2.6" fill="#5fc06e" opacity=".22"/>
        <rect x="26.6" y="34.4" width="6.4" height="4" rx="1" fill="#1b2027" stroke="#39424d" stroke-width=".5"/>
        <rect x="15.4" y="38.6" width="17.2" height="1.4" rx=".7" fill="#fff" opacity=".12"/>
    </svg>`,

    /* ---------------------------------------------------------- fuel can */
    fuelcan: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="fc-body" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0" stop-color="#e8503f"/><stop offset=".3" stop-color="#cf3226"/>
                <stop offset=".7" stop-color="#a8201a"/><stop offset="1" stop-color="#78110d"/>
            </linearGradient>
            <linearGradient id="fc-cap" x1="0" y1="0" x2="1" y2="0">
                <stop offset="0" stop-color="#6a737d"/><stop offset="1" stop-color="#2f353c"/>
            </linearGradient>
        </defs>
        <ellipse cx="24" cy="43.8" rx="15" ry="2.4" fill="#000" opacity=".34"/>
        <path d="M11 12.6h9l4.4 4.2h11.4c1.2 0 2.2 1 2.2 2.2v20.4c0 1.2-1 2.2-2.2 2.2H11c-1.2 0-2.2-1-2.2-2.2V14.8c0-1.2 1-2.2 2.2-2.2z" fill="url(#fc-body)" stroke="#5c0d09" stroke-width=".7"/>
        <path d="M12.4 12.6h6.4l3.8 4.2" fill="none" stroke="#5c0d09" stroke-width="1.4" stroke-linejoin="round"/>
        <rect x="28.4" y="7.6" width="8" height="5.6" rx="1.4" fill="url(#fc-cap)" stroke="#1b2026" stroke-width=".6"/>
        <rect x="29.6" y="6.2" width="5.6" height="2.2" rx="1.1" fill="#545c66"/>
        <path d="M24.6 22.4l-7 8.4h5.2l-2.6 9 9.2-11.2h-5.6l3-6.2z" fill="#ffd9a0" opacity=".92"/>
        <path d="M24.6 22.4l-7 8.4h5.2" fill="#fff" opacity=".18"/>
        <rect x="12.4" y="33.6" width="4" height="6.2" rx="1" fill="#fff" opacity=".12"/>
        <path d="M10.4 18v22.4" stroke="#fff" stroke-opacity=".28" stroke-width="1.8" stroke-linecap="round"/>
        <path d="M36.6 18v21" stroke="#000" stroke-opacity=".25" stroke-width="2.6" stroke-linecap="round"/>
    </svg>`,

    /* ---------------------------------------------------------- backpack */
    backpack: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="bp-body" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0" stop-color="#7f6a4a"/><stop offset=".45" stop-color="#5e4c32"/>
                <stop offset="1" stop-color="#3a2d1c"/>
            </linearGradient>
            <linearGradient id="bp-flap" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#8d7754"/><stop offset="1" stop-color="#4e3f29"/>
            </linearGradient>
            <linearGradient id="bp-gold" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0" stop-color="#f2da90"/><stop offset=".55" stop-color="#d4af37"/>
                <stop offset="1" stop-color="#8f7420"/>
            </linearGradient>
        </defs>
        <ellipse cx="24" cy="44.4" rx="13" ry="2.3" fill="#000" opacity=".32"/>
        <path d="M17.6 13.2V9.8c0-2.6 2.2-4.6 4.8-4.6h3.2c2.6 0 4.8 2 4.8 4.6v3.4" fill="none" stroke="#8d7a58" stroke-width="2.4" stroke-linecap="round"/>
        <path d="M11 17.6c0-3.4 2.8-6.2 6.2-6.2h13.6c3.4 0 6.2 2.8 6.2 6.2v21.4c0 1.8-1.4 3.2-3.2 3.2H14.2c-1.8 0-3.2-1.4-3.2-3.2z" fill="url(#bp-body)" stroke="#241a10" stroke-width=".8"/>
        <path d="M11 22.4h26v-3.2c0-2.6-2-4.8-4.6-4.8H15.6c-2.6 0-4.6 2.2-4.6 4.8z" fill="url(#bp-flap)" stroke="#241a10" stroke-width=".7"/>
        <path d="M11 22.4h26v4.2c0 1.4-1.2 2.6-2.6 2.6H13.6c-1.4 0-2.6-1.2-2.6-2.6z" fill="#000" opacity=".16"/>
        <rect x="19.2" y="20.6" width="9.6" height="5.4" rx="1.4" fill="url(#bp-gold)" stroke="#7a6218" stroke-width=".5"/>
        <rect x="21.4" y="22" width="5.2" height="2.6" rx=".7" fill="#3f3418"/>
        <path d="M12.4 31.4h23.2" stroke="#000" stroke-opacity=".35" stroke-width="1"/>
        <rect x="15" y="33" width="18" height="7.6" rx="1.8" fill="#000" opacity=".16" stroke="#2c2116" stroke-width=".6"/>
        <path d="M19.6 33v2.6" stroke="#d4af37" stroke-opacity=".6" stroke-width="1"/>
        <path d="M13.6 17.6v20.4" stroke="#fff" stroke-opacity=".14" stroke-width="1.8" stroke-linecap="round"/>
        <path d="M9.2 20.4c-2.6 6-2.6 14 0 20" fill="none" stroke="#8d7a58" stroke-width="1.8" stroke-linecap="round"/>
        <path d="M38.8 20.4c2.6 6 2.6 14 0 20" fill="none" stroke="#6b5a3f" stroke-width="1.8" stroke-linecap="round"/>
    </svg>`,

    /* ---------------------------------------------------------- pistol */
    weapon_pistol: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="pp-slide" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#6d7681"/><stop offset=".35" stop-color="#40474f"/>
                <stop offset="1" stop-color="#1c2025"/>
            </linearGradient>
            <linearGradient id="pp-grip" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0" stop-color="#3c434b"/><stop offset="1" stop-color="#15181c"/>
            </linearGradient>
        </defs>
        <path d="M8.6 15.2h29.4c1.4 0 2.6 1.2 2.6 2.6v5.4c0 1.4-1.2 2.6-2.6 2.6h-3.4l1.6 4.6h-8.2l-1.4-4.6H17v5.4c0 3.4-2.8 6-6.2 6H8.6z" fill="url(#pp-slide)" stroke="#0b0d10" stroke-width=".8"/>
        <path d="M9.4 16.6h28.2" stroke="#fff" stroke-opacity=".28" stroke-width="1.2" stroke-linecap="round"/>
        <rect x="12" y="18.6" width="14" height="1.6" rx=".8" fill="#0a0c0f" opacity=".8"/>
        <circle cx="35.4" cy="21.4" r="2.6" fill="#0c0e11" stroke="#4c545d" stroke-width=".7"/>
        <circle cx="35.4" cy="21.4" r="1.1" fill="#20262c"/>
        <path d="M14.4 31.6c0-4.2 2.6-7 6.6-7H30c1.6 0 2.6 1.2 2.6 2.6l-1.4 12.4c-.1 1.2-1.1 2.2-2.4 2.2h-9.4c-1.4 0-2.6-1.2-2.6-2.6z" fill="url(#pp-grip)" stroke="#0b0d10" stroke-width=".8"/>
        <g stroke="#5c656f" stroke-opacity=".55" stroke-width=".7">
            <path d="M17.6 33h12.6"/><path d="M17.4 35.6h12.6"/><path d="M17.2 38.2h12.6"/>
        </g>
        <path d="M20.6 27.4h8.8" stroke="#8d98a3" stroke-opacity=".5" stroke-width="1"/>
        <path d="M24.6 24.6v3" stroke="#0b0d10" stroke-width="1.2"/>
    </svg>`,

    /* ---------------------------------------------------------- deagle */
    weapon_deagle: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="dg-slide" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#f0f3f7"/><stop offset=".3" stop-color="#b9c2cc"/>
                <stop offset=".62" stop-color="#7d868f"/><stop offset="1" stop-color="#4b525a"/>
            </linearGradient>
            <linearGradient id="dg-grip" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0" stop-color="#33383f"/><stop offset="1" stop-color="#101317"/>
            </linearGradient>
            <linearGradient id="dg-gold" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0" stop-color="#f4dc94"/><stop offset=".6" stop-color="#d4af37"/>
                <stop offset="1" stop-color="#8f7420"/>
            </linearGradient>
        </defs>
        <path d="M5.4 13.4h34.2c1.6 0 2.6 1.2 2.6 2.6v7c0 1.6-1.2 2.6-2.6 2.6H30l2 5.4h-9.2l-2-5.4H16v6.6c0 3.2-2.6 5.8-5.8 5.8H6z" fill="url(#dg-slide)" stroke="#2b3037" stroke-width=".8"/>
        <path d="M7 14.8h33" stroke="#fff" stroke-opacity=".7" stroke-width="1.6" stroke-linecap="round"/>
        <path d="M7.4 24.2h30" stroke="#000" stroke-opacity=".35" stroke-width="1"/>
        <g stroke="#39414a" stroke-width=".7" opacity=".85">
            <path d="M10 17.6h11"/><path d="M10 20h11"/>
        </g>
        <circle cx="36.4" cy="20" r="3" fill="#3c434b" stroke="#e4eaf0" stroke-opacity=".5" stroke-width=".6"/>
        <circle cx="36.4" cy="20" r="1.2" fill="#0e1115"/>
        <path d="M14 30.4c0-4.4 3-7.4 7-7.4h8.4c1.6 0 2.8 1.4 2.6 3l-1.6 13.4c-.1 1.2-1.2 2.2-2.4 2.2h-9.4c-1.4 0-2.6-1.2-2.6-2.6z" fill="url(#dg-grip)" stroke="#080a0d" stroke-width=".8"/>
        <g stroke="#c9d0d8" stroke-opacity=".22" stroke-width=".8">
            <path d="M17 32.4h11.4"/><path d="M16.8 35h11.4"/><path d="M16.6 37.6h11.4"/>
        </g>
        <path d="M23.4 25.4v3.2" stroke="#101317" stroke-width="1.4"/>
        <rect x="8.6" y="20.6" width="6" height="2" rx="1" fill="url(#dg-gold)" opacity=".9"/>
    </svg>`,

    /* ---------------------------------------------------------- shotgun */
    weapon_shotgun: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="sg-steel" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#8b949e"/><stop offset=".28" stop-color="#4c545d"/>
                <stop offset=".72" stop-color="#262b31"/><stop offset="1" stop-color="#12161a"/>
            </linearGradient>
            <linearGradient id="sg-wood" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#a86a34"/><stop offset=".45" stop-color="#7c4a1f"/>
                <stop offset="1" stop-color="#4c2a0f"/>
            </linearGradient>
        </defs>
        <path d="M3.4 15.4h34.2c1.4 0 2.4 1 2.4 2.4v4.6c0 1.4-1 2.4-2.4 2.4H20.4l-1 3.6h-7l1.2-3.6H3.4z" fill="url(#sg-steel)" stroke="#0a0d10" stroke-width=".7"/>
        <path d="M4.6 16.6h32.6" stroke="#fff" stroke-opacity=".35" stroke-width="1.2" stroke-linecap="round"/>
        <path d="M33.4 9.6h6.8c1 0 1.8.8 1.8 1.8v4.2h-8.6z" fill="url(#sg-steel)" stroke="#0a0d10" stroke-width=".7"/>
        <path d="M12 25.4h20.6c1.2 0 2 .8 2 2v5.2c0 1.2-.8 2-2 2H12c-1.2 0-2-.8-2-2v-5.2c0-1.2.8-2 2-2z" fill="url(#sg-wood)" stroke="#3a1f0a" stroke-width=".7"/>
        <g stroke="#3a1f0a" stroke-opacity=".55" stroke-width=".7">
            <path d="M13 27.6h18.6"/><path d="M13 30h18.6"/><path d="M13 32.4h18.6"/>
        </g>
        <path d="M8.6 17.6h9.2v6.2H8.6z" fill="#1b2026" opacity=".7"/>
        <path d="M4.4 20.8h6.2" stroke="#0a0d10" stroke-width="1.4"/>
        <circle cx="39.4" cy="17.4" r="1.2" fill="#0d1013"/>
        <path d="M24 24.2v1.4" stroke="#8b949e" stroke-width="1.2"/>
        <path d="M27.6 24.2v1.4" stroke="#8b949e" stroke-width="1.2"/>
    </svg>`,

    /* ---------------------------------------------------------- ak-47 */
    weapon_ak: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="ak-wood" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#b5793c"/><stop offset=".4" stop-color="#8a5426"/>
                <stop offset="1" stop-color="#502c0f"/>
            </linearGradient>
            <linearGradient id="ak-steel" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#767f89"/><stop offset=".35" stop-color="#3f464e"/>
                <stop offset="1" stop-color="#14181c"/>
            </linearGradient>
        </defs>
        <path d="M2.6 16.4h31.8v-2.8h5.2v2.8h4.8c.8 0 1.4.6 1.4 1.4v3.4c0 .8-.6 1.4-1.4 1.4H28.6l-1.4 4.2h-6.8l1.2-4.2H2.6z" fill="url(#ak-steel)" stroke="#0a0c0f" stroke-width=".7"/>
        <path d="M3.8 17.4h30.6" stroke="#fff" stroke-opacity=".22" stroke-width="1.1" stroke-linecap="round"/>
        <path d="M2.6 16.4h12.2c.8 0 1.4.6 1.4 1.4v.6H2.6z" fill="url(#ak-wood)"/>
        <path d="M15.6 20.8h19.6c1 0 1.8.8 1.8 1.8v4c0 1-.8 1.8-1.8 1.8H17.4c-1 0-1.8-.8-1.8-1.8v-4c0-1 .8-1.8 1.8-1.8z" fill="url(#ak-wood)" stroke="#3c2109" stroke-width=".7"/>
        <path d="M18.4 25.2c1.6 5.2 3.4 9.6 5 13.4h4.2c-1.4-4.2-3-8.6-4.6-13.4z" fill="url(#ak-steel)" stroke="#0a0c0f" stroke-width=".7"/>
        <path d="M23.4 30.4c1.4 2.8 2.6 5.4 3.4 7.6" stroke="#8c959f" stroke-opacity=".45" stroke-width="1"/>
        <path d="M8.6 24.4c0-4.6 3-7.6 7-7.6h6.4c1.4 0 2.4 1.2 2.2 2.6l-1.8 14.2c-.1 1-1 1.8-2 1.8h-7c-1.2 0-2.2-1-2.2-2.2z" fill="url(#ak-wood)" stroke="#3c2109" stroke-width=".8"/>
        <path d="M29.4 12.4h3.4v4.2h-3.4z" fill="url(#ak-steel)"/>
        <path d="M30 11.6h1.8v2.4H30z" fill="#4b535c"/>
        <path d="M25.6 8.6h1.6v4.4h-1.6z" fill="url(#ak-steel)"/>
        <path d="M30.4 20.4c0-1.6 1.4-2.8 3-2.8s3 1.2 3 2.8" fill="none" stroke="#2c3238" stroke-width="1.4"/>
        <path d="M40.6 17.4h3.4v4.6h-3.4z" fill="#20262c" stroke="#0a0c0f" stroke-width=".6"/>
    </svg>`,

    /* ---------------------------------------------------------- watch */
    watch: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="wt2-gold" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0" stop-color="#fbeec2"/><stop offset=".35" stop-color="#e2c364"/>
                <stop offset=".7" stop-color="#c39c2c"/><stop offset="1" stop-color="#8a6c17"/>
            </linearGradient>
            <linearGradient id="wt2-strap" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#3d434b"/><stop offset="1" stop-color="#15181c"/>
            </linearGradient>
        </defs>
        <path d="M18 4h12v10H18z" fill="url(#wt2-strap)"/>
        <path d="M18 34h12v10H18z" fill="url(#wt2-strap)"/>
        <g stroke="#000" stroke-opacity=".4" stroke-width=".6">
            <path d="M18 7h12"/><path d="M18 10.4h12"/><path d="M18 37h12"/><path d="M18 40.4h12"/>
        </g>
        <circle cx="24" cy="24" r="13.6" fill="url(#wt2-gold)" stroke="#6f5612" stroke-width=".8"/>
        <circle cx="24" cy="24" r="10.8" fill="#0f1216"/>
        <circle cx="24" cy="24" r="10.8" fill="none" stroke="#555f6b" stroke-width=".6"/>
        <path d="M24 16.6V24l5 3" fill="none" stroke="#e6ebf0" stroke-width="1.6" stroke-linecap="round"/>
        <circle cx="24" cy="24" r="1.2" fill="#d4af37"/>
        <g fill="#8f97a3" opacity=".8">
            <circle cx="24" cy="15.8" r=".55"/><circle cx="32.4" cy="24" r=".55"/>
            <circle cx="24" cy="32.2" r=".55"/><circle cx="15.6" cy="24" r=".55"/>
        </g>
        <path d="M14.6 14.2a13.4 13.4 0 0 1 9-5.4" fill="none" stroke="#fff" stroke-opacity=".65" stroke-width="1.6" stroke-linecap="round"/>
        <rect x="34.4" y="22.4" width="2.6" height="3.2" rx="1" fill="url(#wt2-gold)" stroke="#6f5612" stroke-width=".5"/>
    </svg>`,

    /* ---------------------------------------------------------- default crate */
    default: `<svg viewBox="0 0 48 48" aria-hidden="true">
        <defs>
            <linearGradient id="df-wood" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0" stop-color="#b98b52"/><stop offset=".5" stop-color="#8a5f30"/>
                <stop offset="1" stop-color="#4d3216"/>
            </linearGradient>
            <linearGradient id="df-gold" x1="0" y1="0" x2="1" y2="1">
                <stop offset="0" stop-color="#f4dc94"/><stop offset=".55" stop-color="#d4af37"/>
                <stop offset="1" stop-color="#8f7420"/>
            </linearGradient>
        </defs>
        <rect x="6.4" y="8.4" width="35.2" height="32.2" rx="2.4" fill="url(#df-wood)" stroke="#3a250f" stroke-width=".8"/>
        <rect x="6.4" y="8.4" width="35.2" height="5.4" rx="2.4" fill="#000" opacity=".16"/>
        <g stroke="#3a250f" stroke-opacity=".6" stroke-width="1">
            <path d="M11 14.4v25.6"/><path d="M37 14.4v25.6"/>
            <path d="M6.4 22.4h35.2"/><path d="M6.4 29.4h35.2"/>
        </g>
        <path d="M17 18.6l7 6.4 7-6.4v5.2l-7 6.4-7-6.4z" fill="url(#df-gold)" opacity=".9"/>
        <rect x="20.4" y="30.4" width="7.2" height="4.6" rx="1.2" fill="url(#df-gold)" stroke="#7a6218" stroke-width=".5"/>
        <path d="M8.6 12.6v25" stroke="#fff" stroke-opacity=".2" stroke-width="1.6" stroke-linecap="round"/>
    </svg>`
};
