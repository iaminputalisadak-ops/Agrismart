/// Preset farming questions and short answers — tap to select, no typing required.
class FarmingAssistantQa {
  const FarmingAssistantQa({
    required this.category,
    required this.question,
    required this.answer,
  });

  final String category;
  final String question;
  final String answer;
}

/// Categories shown as filter chips (order matters for display).
const List<String> kFarmingAssistantCategories = [
  'All',
  'Pests & disease',
  'Fertilizer & nutrition',
  'Soil & land',
  'Seeds & crops',
  'Irrigation & water',
  'Organic & safety',
  'Post-harvest',
];

const List<FarmingAssistantQa> kFarmingAssistantQaBank = [
  FarmingAssistantQa(
    category: 'Pests & disease',
    question: 'Yellow leaves on tomato — what might it be?',
    answer:
        'Often nitrogen lack, overwatering, or early blight. Improve drainage, avoid wetting foliage, and use a balanced feed; if spots spread, check for blight and remove infected leaves.',
  ),
  FarmingAssistantQa(
    category: 'Pests & disease',
    question: 'Whiteflies on vegetables — what to do?',
    answer:
        'Use yellow sticky traps, strong water spray to knock adults down, and neem oil in evenings. Encourage beneficial insects; rotate crops next season.',
  ),
  FarmingAssistantQa(
    category: 'Pests & disease',
    question: 'Brown planthopper risk in rice',
    answer:
        'Avoid excess nitrogen, maintain shallow water then alternate wet/dry where suitable, and scout fields weekly. Consult local extension for approved products if thresholds are exceeded.',
  ),
  FarmingAssistantQa(
    category: 'Pests & disease',
    question: 'Stem borer in maize — prevention',
    answer:
        'Destroy crop residues, plant at recommended time to escape peak moth flights, and consider tolerant hybrids where available.',
  ),
  FarmingAssistantQa(
    category: 'Pests & disease',
    question: 'Aphids on mustard / oilseed',
    answer:
        'Encourage ladybirds; if heavy, timely irrigation can help wash small colonies. Follow label-only treatments from your agricultural officer.',
  ),
  FarmingAssistantQa(
    category: 'Pests & disease',
    question: 'Fungal spots after heavy rain',
    answer:
        'Improve air flow (wider spacing), avoid overhead irrigation, and remove lower infected leaves. Copper-based sprays may help early; confirm diagnosis locally.',
  ),
  FarmingAssistantQa(
    category: 'Pests & disease',
    question: 'Cutworm seedlings eaten at night',
    answer:
        'Collars around stems, shallow evening scouting, and clean fields reduce risk. Baits exist where legally permitted—ask extension.',
  ),
  FarmingAssistantQa(
    category: 'Pests & disease',
    question: 'Termite mud tubes near cotton stalks',
    answer:
        'Improve drainage, avoid fresh manure against stems, and consult pest control for registered soil treatments in your area.',
  ),
  FarmingAssistantQa(
    category: 'Fertilizer & nutrition',
    question: 'Best starter feed for wheat after sowing?',
    answer:
        'A light phosphorus-rich starter or DAP band near seed (per local practice) plus soil test for N. Split nitrogen across tillering and jointing stages.',
  ),
  FarmingAssistantQa(
    category: 'Fertilizer & nutrition',
    question: 'Potato needs most: N, P, or K?',
    answer:
        'Potassium is critical for tuber quality; nitrogen drives haulm but excess delays bulking. Balance with soil test and split K near tuber initiation.',
  ),
  FarmingAssistantQa(
    category: 'Fertilizer & nutrition',
    question: 'Maize showing purple leaves early',
    answer:
        'Often phosphorus deficiency in cold/wet soils. Sidedress P if tests show low levels; ensure good root growth and drainage.',
  ),
  FarmingAssistantQa(
    category: 'Fertilizer & nutrition',
    question: 'Organic manure before rice transplant',
    answer:
        'Well-decomposed FYM 2–4 weeks before puddling is common. Avoid fresh manure in standing water to reduce methane and disease risk.',
  ),
  FarmingAssistantQa(
    category: 'Fertilizer & nutrition',
    question: 'Micronutrient spray for legumes',
    answer:
        'If soil tests show Zn/B shortage, foliar sprays at flowering can help pod set. Do not exceed label rates—toxicity is easy with boron.',
  ),
  FarmingAssistantQa(
    category: 'Fertilizer & nutrition',
    question: 'Sugarcane ratoon nutrition',
    answer:
        'Higher K and full N replacement vs plant crop; soil test and add silicon where recommended for lodging resistance.',
  ),
  FarmingAssistantQa(
    category: 'Fertilizer & nutrition',
    question: 'Tomato fruit blossom-end rot',
    answer:
        'Usually calcium uptake issue linked to uneven watering. Mulch, steady irrigation, and avoid ammonium-heavy N surges.',
  ),
  FarmingAssistantQa(
    category: 'Soil & land',
    question: 'Loamy soil — best crops?',
    answer:
        'Loam suits most cereals, vegetables, and legumes. Rotate cereals with legumes to maintain organic matter and nitrogen.',
  ),
  FarmingAssistantQa(
    category: 'Soil & land',
    question: 'Heavy clay waterlogged after rain',
    answer:
        'Raise beds, add organic matter yearly, and install field drains where possible. Avoid tillage when too wet to prevent compaction.',
  ),
  FarmingAssistantQa(
    category: 'Soil & land',
    question: 'Sandy soil dries too fast',
    answer:
        'Mulch, drip or frequent light irrigation, and compost to raise water-holding capacity. Split fertilizer into smaller doses.',
  ),
  FarmingAssistantQa(
    category: 'Soil & land',
    question: 'Soil pH too acidic for wheat',
    answer:
        'Lime based on soil test (often autumn before wheat). Do not guess rates—over-liming harms micronutrients.',
  ),
  FarmingAssistantQa(
    category: 'Soil & land',
    question: 'Green manure before rice',
    answer:
        'Sesbania/dhaincha 4–6 weeks before transplant, incorporate at flowering for biomass and N contribution.',
  ),
  FarmingAssistantQa(
    category: 'Soil & land',
    question: 'Erosion on sloping vegetable plot',
    answer:
        'Contour beds, grass strips, mulch, and avoid bare soil in monsoon. Terracing if slope is steep.',
  ),
  FarmingAssistantQa(
    category: 'Seeds & crops',
    question: 'Wheat seed rate rough guide',
    answer:
        'Depends on variety and sowing date—often 100–125 kg/ha for conventional drill; follow seed bag and local extension chart.',
  ),
  FarmingAssistantQa(
    category: 'Seeds & crops',
    question: 'Hybrid vs OPV maize — when hybrid?',
    answer:
        'Hybrids suit good management and market access; OPVs help seed saving where hybrids are costly. Match to moisture and fertility.',
  ),
  FarmingAssistantQa(
    category: 'Seeds & crops',
    question: 'Rice direct-seeded vs transplant',
    answer:
        'DSR saves water/labor but needs weed control and level fields. Transplant suits weed-heavy areas and stable water.',
  ),
  FarmingAssistantQa(
    category: 'Seeds & crops',
    question: 'Potato seed tuber size',
    answer:
        'Use certified seed; cut large tubers with 2–3 eyes and cure cuts. Small whole tubers reduce disease spread risk.',
  ),
  FarmingAssistantQa(
    category: 'Seeds & crops',
    question: 'Cotton planting spacing',
    answer:
        'Follow local Bt/non-Bt recommendations—too dense increases humidity and boll rot; too wide wastes land.',
  ),
  FarmingAssistantQa(
    category: 'Seeds & crops',
    question: 'Mustard sowing window too late?',
    answer:
        'Late sowing reduces branching and yield. Increase density slightly only if extension advises; frost risk rises at tail end.',
  ),
  FarmingAssistantQa(
    category: 'Irrigation & water',
    question: 'Rice alternate wetting and drying basics',
    answer:
        'Let field dry to −15 to −20 kPa (or crack lightly) then re-flood shallowly. Saves water; monitor weed flush and nutrient.',
  ),
  FarmingAssistantQa(
    category: 'Irrigation & water',
    question: 'Drip for vegetable rows',
    answer:
        'Emitters 30–40 cm apart for most solanums; flush lines monthly, filter water, and schedule by soil moisture not clock-only.',
  ),
  FarmingAssistantQa(
    category: 'Irrigation & water',
    question: 'Wheat critical irrigation stages',
    answer:
        'Crown root, tillering, jointing, flowering, and milk stages matter most—shortage at flowering hurts grain most.',
  ),
  FarmingAssistantQa(
    category: 'Irrigation & water',
    question: 'Overhead vs furrow for tomatoes',
    answer:
        'Furrow/drip reduces leaf wetness and disease. Overhead is cheaper but raises blight risk—morning irrigation only if used.',
  ),
  FarmingAssistantQa(
    category: 'Irrigation & water',
    question: 'Water quality: slightly saline',
    answer:
        'Leach with extra water where drainage exists, choose tolerant crops, and avoid chloride-heavy fertilizers if sodium is high—test water.',
  ),
  FarmingAssistantQa(
    category: 'Organic & safety',
    question: 'Pre-harvest interval (PHI) reminder',
    answer:
        'Never harvest before PHI on the pesticide label. PHI protects consumers—violations risk market rejection.',
  ),
  FarmingAssistantQa(
    category: 'Organic & safety',
    question: 'PPE when spraying',
    answer:
        'Long sleeves, gloves, goggles, and mask rated for chemicals. Change clothes away from family water sources.',
  ),
  FarmingAssistantQa(
    category: 'Organic & safety',
    question: 'Compost maturity check',
    answer:
        'Dark, crumbly, earthy smell, no ammonia. Immature compost can burn roots and tie up nitrogen.',
  ),
  FarmingAssistantQa(
    category: 'Organic & safety',
    question: 'Neem oil timing',
    answer:
        'Evening application reduces bee exposure; repeat per label; avoid mixing unknown adjuvants.',
  ),
  FarmingAssistantQa(
    category: 'Post-harvest',
    question: 'Potato storage ventilation',
    answer:
        'Cure 7–10 days at 10–15°C then cool slowly to 2–4°C for table stock. Avoid light to prevent greening.',
  ),
  FarmingAssistantQa(
    category: 'Post-harvest',
    question: 'Tomato grading for market',
    answer:
        'Sort by size/color/defects; pack same stage together. Do not mix overripe with firm fruit.',
  ),
  FarmingAssistantQa(
    category: 'Post-harvest',
    question: 'Grain moisture before bag storage',
    answer:
        'Target safe moisture per crop (often ~12–14% for cereals—verify local chart). Use meter, not guesswork.',
  ),
  FarmingAssistantQa(
    category: 'Post-harvest',
    question: 'Reducing rice field losses at harvest',
    answer:
        'Sharp cutter bar, correct combine settings, and timely harvest near 20–22% moisture where machine harvest is used.',
  ),
  FarmingAssistantQa(
    category: 'Pests & disease',
    question: 'Fall armyworm in maize — first signs',
    answer:
        'Window-pane feeding in whorl. Remove frass, scout early, and follow national IPM guidelines for your region.',
  ),
  FarmingAssistantQa(
    category: 'Fertilizer & nutrition',
    question: 'Basal DAP for rice transplant',
    answer:
        'Common practice where recommended: part of P basally with Zn if deficient soils. Confirm with soil test and local package.',
  ),
  FarmingAssistantQa(
    category: 'Seeds & crops',
    question: 'Intercrop legume with cereals — benefit?',
    answer:
        'Fixes N, breaks pest cycles, diversifies income—match row ratios to machinery and water availability.',
  ),
  FarmingAssistantQa(
    category: 'Soil & land',
    question: 'Zero till wheat after rice',
    answer:
        'Saves time/water/residue; needs happy seeder and good weed plan. Not ideal on poorly drained fields.',
  ),
  FarmingAssistantQa(
    category: 'Irrigation & water',
    question: 'Check soil moisture without gadgets',
    answer:
        'Feel soil at root depth: form a ball—if crumbles, likely needs water; if muddy, wait. Calibrate with crop stage.',
  ),
];
