/* iLARS store pictures: the two people, drawn once, used by screens/strip.html and hero/hero.html.
   Each is an SVG <symbol> (viewBox -14 -14 428 428): a white ring, a soft round background,
   a faceless flat figure where every shape has a second (shadow) tone, and a little grain.
     #pat  the PATIENT: a woman in her fifties, short wavy hair, soft orange-peach cardigan over a light top;
           turned a little to the right.
     #doc  her DOCTOR: a man, navy scrubs, stethoscope, glasses; turned a little to the left.
   Call ilarsPeople() once; it puts the symbols into the page. */
function ilarsPeople() {
  const svg = `
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
  <defs>
    <radialGradient id="gPatBg" cx="35%" cy="28%" r="80%">
      <stop offset="0" stop-color="#F3EFFF"/><stop offset=".6" stop-color="#DED5FF"/><stop offset="1" stop-color="#CABDF8"/>
    </radialGradient>
    <radialGradient id="gDocBg" cx="35%" cy="28%" r="80%">
      <stop offset="0" stop-color="#EEEEFF"/><stop offset=".6" stop-color="#D3D7FF"/><stop offset="1" stop-color="#BCC1F7"/>
    </radialGradient>
    <filter id="avGrain" x="0" y="0" width="100%" height="100%">
      <feTurbulence type="fractalNoise" baseFrequency="1.1" numOctaves="2" seed="4"/>
      <feColorMatrix values="0 0 0 0 .2  0 0 0 0 .16  0 0 0 0 .35  0 0 0 1.4 -.35"/>
    </filter>
    <clipPath id="cCirc"><circle cx="200" cy="200" r="200"/></clipPath>
    <clipPath id="cPatHead"><ellipse cx="204" cy="166" rx="53" ry="63"/></clipPath>
    <clipPath id="cDocHead"><ellipse cx="194" cy="166" rx="56" ry="64"/></clipPath>
    <clipPath id="cPatBody"><path d="M10 420 C 18 344, 72 306, 150 294 L 250 294 C 328 306, 382 344, 390 420 Z"/></clipPath>
    <clipPath id="cDocBody"><path d="M8 420 C 16 342, 70 302, 150 288 L 254 288 C 332 302, 384 342, 392 420 Z"/></clipPath>

    <!-- PATIENT -->
    <symbol id="pat" viewBox="-14 -14 428 428">
      <circle cx="200" cy="200" r="207" fill="#fff"/>
      <g clip-path="url(#cCirc)">
        <rect x="0" y="0" width="400" height="400" fill="url(#gPatBg)"/>
        <g transform="translate(200 430) scale(1.24) translate(-200 -430)">
        <!-- back hair: a short wavy bob, behind the head; frames the face on the right -->
        <g transform="translate(0 20)">
          <path d="M204 82 C 160 80, 130 110, 132 150 C 128 170, 134 186, 130 200 C 128 214, 140 224, 152 220 C 160 230, 176 228, 182 218 L 230 210 C 250 216, 266 206, 266 190 C 274 176, 272 160, 268 146 C 266 104, 240 82, 204 82 Z" fill="#7B5D49"/>
          <path d="M140 184 C 136 194, 142 202, 138 212" stroke="#5F4535" stroke-width="4" fill="none" stroke-linecap="round"/>
          <path d="M262 168 C 268 178, 262 188, 266 196" stroke="#5F4535" stroke-width="4" fill="none" stroke-linecap="round"/>
        </g>
        <!-- neck -->
        <path d="M184 228 L222 228 L226 298 Q204 312 180 298 Z" fill="#EDC2A4"/>
        <path d="M184 236 Q204 270 224 240 L225 268 Q204 286 182 266 Z" fill="#D9A585"/>
        <!-- cardigan -->
        <path d="M10 420 C 18 344, 72 306, 150 294 L 250 294 C 328 306, 382 344, 390 420 Z" fill="#FFB07E"/>
        <g clip-path="url(#cPatBody)">
          <path d="M262 296 C 330 314, 362 352, 364 420 L 420 420 L 420 280 Z" fill="#EE8F57"/>
          <path d="M10 420 C 22 362, 52 332, 98 316 C 72 344, 62 384, 64 420 Z" fill="#FFC7A2"/>
          <path d="M84 420 C 86 382, 96 354, 112 338" stroke="#F49A63" stroke-width="5" fill="none" stroke-linecap="round"/>
          <path d="M318 420 C 316 386, 308 360, 294 342" stroke="#DE7E46" stroke-width="5" fill="none" stroke-linecap="round"/>
        </g>
        <!-- light top with a soft scoop neck, seen in the open cardigan -->
        <path d="M156 290 L244 290 L240 298 C 224 322, 176 322, 160 298 Z" fill="#EDC2A4"/>
        <path d="M200 318 C 222 316, 234 306, 240 298 L 244 290 L 230 290 C 226 302, 214 310, 200 312 Z" fill="#D9A585"/>
        <path d="M160 298 C 176 322, 224 322, 240 298 L 230 420 L 170 420 Z" fill="#F8F6F2"/>
        <path d="M206 319 C 222 316, 234 308, 240 298 L 230 420 L 208 420 Z" fill="#E7E3EC"/>
        <!-- cardigan front edges -->
        <path d="M150 294 L 162 298 C 172 338, 176 380, 176 420 L 156 420 C 156 380, 150 340, 140 302 Z" fill="#FFC4A0"/>
        <path d="M250 294 L 238 298 C 228 338, 224 380, 224 420 L 246 420 C 246 380, 252 340, 262 302 Z" fill="#F39860"/>
        <circle cx="168" cy="372" r="5" fill="#FFF2E8"/><circle cx="170" cy="404" r="5" fill="#FFF2E8"/>
        <g transform="translate(0 20)">
          <!-- ear (left: she faces right) and a tiny earring -->
          <ellipse cx="152" cy="180" rx="11" ry="16" fill="#E8B898"/>
          <ellipse cx="154" cy="181" rx="5" ry="9" fill="#D39B7A"/>
          <circle cx="151" cy="199" r="4.5" fill="#F4E6BE"/>
          <!-- head -->
          <g clip-path="url(#cPatHead)">
            <rect x="140" y="96" width="130" height="140" fill="#E3AF8F"/>
            <ellipse cx="211" cy="160" rx="53" ry="63" fill="#F4D0B5"/>
          </g>
          <!-- front hair: crown and a soft side-swept wave over the forehead -->
          <path d="M136 172 C 128 128, 154 90, 202 88 C 240 86, 266 108, 266 146 C 260 136, 250 130, 240 132 C 226 134, 214 128, 204 120 C 192 132, 172 140, 162 152 C 158 162, 156 170, 152 174 C 146 172, 140 172, 136 172 Z" fill="#9A7A60"/>
          <path d="M136 172 C 130 140, 140 112, 160 96 C 150 120, 152 150, 156 168 C 150 172, 142 172, 136 172 Z" fill="#7B5D49"/>
          <path d="M204 120 C 196 130, 182 136, 170 144" stroke="#7B5D49" stroke-width="4" fill="none" stroke-linecap="round"/>
          <path d="M168 108 C 184 98, 204 94, 222 98" stroke="#B89A7E" stroke-width="5" fill="none" stroke-linecap="round"/>
          <path d="M230 102 C 246 108, 258 120, 262 136" stroke="#B89A7E" stroke-width="5" fill="none" stroke-linecap="round"/>
          <path d="M190 92 C 210 88, 232 92, 248 104" stroke="#D8CEC6" stroke-width="4" fill="none" stroke-linecap="round"/>
          <!-- cheek -->
          <ellipse cx="238" cy="192" rx="13" ry="8" fill="#EBA08E" opacity=".45"/>
        </g></g>
        <rect x="0" y="0" width="400" height="400" filter="url(#avGrain)" opacity=".06"/>
      </g>
      <circle cx="200" cy="200" r="200" fill="none" stroke="#fff" stroke-width="12"/>
    </symbol>

    <!-- DOCTOR -->
    <symbol id="doc" viewBox="-14 -14 428 428">
      <circle cx="200" cy="200" r="207" fill="#fff"/>
      <g clip-path="url(#cCirc)">
        <rect x="0" y="0" width="400" height="400" fill="url(#gDocBg)"/>
        <g transform="translate(200 430) scale(1.24) translate(-200 -430)">
        <!-- neck -->
        <path d="M176 226 L222 226 L228 298 Q200 314 170 298 Z" fill="#B67E58"/>
        <path d="M176 236 Q200 272 222 240 L226 266 Q200 286 172 264 Z" fill="#9A6342"/>
        <!-- navy scrubs -->
        <path d="M8 420 C 16 342, 70 302, 150 288 L 254 288 C 332 302, 384 342, 392 420 Z" fill="#2B3A7A"/>
        <g clip-path="url(#cDocBody)">
          <path d="M268 290 C 330 312, 360 350, 362 420 L 420 420 L 420 280 Z" fill="#202C62"/>
          <path d="M8 420 C 20 360, 50 330, 96 312 C 70 340, 60 380, 62 420 Z" fill="#37498F"/>
          <path d="M84 420 C 86 380, 96 352, 112 336" stroke="#22306A" stroke-width="5" fill="none" stroke-linecap="round"/>
          <path d="M318 420 C 316 384, 308 358, 294 340" stroke="#1A2452" stroke-width="5" fill="none" stroke-linecap="round"/>
          <!-- chest pocket with a pen -->
          <rect x="246" y="350" width="52" height="44" rx="6" fill="#24316B"/>
          <rect x="246" y="350" width="52" height="9" rx="4" fill="#1D2859"/>
          <rect x="282" y="334" width="7" height="26" rx="3" fill="#E4E9F4"/>
          <rect x="282" y="334" width="3" height="26" rx="1.5" fill="#C3CBDD"/>
        </g>
        <!-- V-neck -->
        <path d="M170 288 L 202 336 L 234 288 Z" fill="#B67E58"/>
        <path d="M202 336 L 234 288 L 220 288 L 202 316 Z" fill="#9A6342"/>
        <path d="M166 288 L 202 342 L 238 288" stroke="#1C2654" stroke-width="9" fill="none" stroke-linejoin="round"/>
        <!-- stethoscope -->
        <path d="M172 292 C 148 320, 144 354, 160 382" stroke="#D5DCEA" stroke-width="10" fill="none" stroke-linecap="round"/>
        <path d="M170 296 C 150 322, 148 352, 160 376" stroke="#F3F6FB" stroke-width="3" fill="none" stroke-linecap="round"/>
        <path d="M234 292 C 258 318, 258 344, 246 364" stroke="#B9C3D7" stroke-width="10" fill="none" stroke-linecap="round"/>
        <circle cx="246" cy="366" r="7" fill="#B9C3D7"/>
        <circle cx="160" cy="394" r="18" fill="#C9D1E1"/>
        <circle cx="160" cy="394" r="18" fill="none" stroke="#8D99B2" stroke-width="5"/>
        <circle cx="155" cy="389" r="5" fill="#F1F4FA"/>
        <g transform="translate(0 18)">
          <!-- ear (right: he faces left) -->
          <ellipse cx="248" cy="178" rx="12" ry="17" fill="#BC8460"/>
          <ellipse cx="246" cy="179" rx="5" ry="9" fill="#9E6744"/>
          <!-- head -->
          <g clip-path="url(#cDocHead)">
            <rect x="130" y="96" width="140" height="140" fill="#A96F4B"/>
            <ellipse cx="187" cy="160" rx="56" ry="64" fill="#C48C66"/>
            <!-- short trimmed beard along the jaw -->
            <path d="M136 176 L 136 240 L 256 240 L 256 176 C 252 194, 240 204, 222 207 C 206 209, 194 213, 182 213 C 164 213, 148 200, 136 176 Z" fill="#352B29"/>
            <path d="M222 207 C 240 204, 252 194, 256 176 L 256 240 L 226 240 C 232 228, 230 216, 222 207 Z" fill="#261F1E"/>
          </g>
          <!-- short dark hair -->
          <path d="M136 160 C 130 118, 160 90, 202 90 C 242 90, 266 116, 262 158 C 262 170, 260 178, 256 184 L 250 178 C 250 164, 248 152, 240 146 C 226 134, 206 128, 186 126 C 170 124, 154 130, 146 140 C 142 146, 138 152, 136 160 Z" fill="#2A2322"/>
          <path d="M262 160 C 262 170, 260 178, 256 184 L 250 178 C 250 162, 246 150, 236 144 C 248 140, 258 146, 262 160 Z" fill="#3D3331"/>
          <path d="M152 120 C 170 104, 196 98, 224 102" stroke="#4B403D" stroke-width="5" fill="none" stroke-linecap="round"/>
          <!-- glasses -->
          <g stroke="#1F2742" stroke-width="5" stroke-linejoin="round">
            <rect x="148" y="164" width="28" height="22" rx="8" fill="#fff" fill-opacity=".3"/>
            <rect x="186" y="164" width="30" height="22" rx="8" fill="#fff" fill-opacity=".3"/>
            <path d="M176 172 Q 181 167 186 172" fill="none"/>
            <path d="M216 170 L 242 172" fill="none"/>
          </g>
          <path d="M192 170 L 198 168" stroke="#fff" stroke-width="3" stroke-linecap="round" opacity=".8"/>
          <!-- cheek -->
          <ellipse cx="162" cy="198" rx="12" ry="7" fill="#9E5240" opacity=".28"/>
        </g></g>
        <rect x="0" y="0" width="400" height="400" filter="url(#avGrain)" opacity=".06"/>
      </g>
      <circle cx="200" cy="200" r="200" fill="none" stroke="#fff" stroke-width="12"/>
    </symbol>
  </defs>
</svg>`;
  document.body.insertAdjacentHTML('afterbegin', svg);
}
