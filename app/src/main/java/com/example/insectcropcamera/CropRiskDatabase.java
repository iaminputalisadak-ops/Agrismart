package com.example.insectcropcamera;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class CropRiskDatabase {

    private final Map<String, Set<String>> harmfulMap = new HashMap<>();

    public CropRiskDatabase() {
        add("rice", "brown planthopper", "leaf folder", "stem borer", "rice bug", "grasshopper", "aphid");
        add("maize", "fall armyworm", "stem borer", "cutworm", "aphid", "grasshopper");
        add("wheat", "aphid", "armyworm", "termite", "grasshopper");
        add("potato", "potato tuber moth", "aphid", "whitefly", "cutworm", "beetle");
        add("tomato", "whitefly", "aphid", "fruit borer", "leaf miner", "thrips", "caterpillar");
        add("mustard", "aphid", "sawfly", "painted bug", "leaf miner");
        add("sugarcane", "early shoot borer", "top borer", "termite", "whitefly", "scale insect");
        add("cotton", "bollworm", "whitefly", "aphid", "jassid", "thrips");
    }

    private void add(String crop, String... insects) {
        Set<String> set = new HashSet<>();

        for (String insect : insects) {
            set.add(insect.toLowerCase());
        }

        harmfulMap.put(crop.toLowerCase(), set);
    }

    public boolean isHarmful(String insect, String crop) {
        if (insect == null || crop == null) return false;

        String insectLower = insect.toLowerCase();
        String cropLower = crop.toLowerCase();

        if (!harmfulMap.containsKey(cropLower)) return false;

        Set<String> harmfulInsects = harmfulMap.get(cropLower);

        for (String harmful : harmfulInsects) {
            if (insectLower.contains(harmful) || harmful.contains(insectLower)) {
                return true;
            }
        }

        return false;
    }

    public String getAdvice(String insect, String crop, boolean harmful) {
        if (!harmful) {
            return "This insect is not listed as a major harmful pest for " + crop
                    + ". Still monitor the field regularly.";
        }

        return "This insect may damage " + crop + ". Recommended action: inspect nearby plants, "
                + "check infestation level, remove heavily affected leaves if possible, and contact an agriculture expert "
                + "before using pesticide.";
    }
}
