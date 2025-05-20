package com.example.api.controller.statistic;

public enum TimeGroupType {
    YEAR("Năm"),
    QUARTER("Quý"),
    MONTH("Tháng"),
    WEEK("Tuần");

    private final String label;

    TimeGroupType(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    public static TimeGroupType fromLabel(String label) {
        for (TimeGroupType type : values()) {
            if (type.label.equalsIgnoreCase(label)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Invalid time group label: " + label);
    }
}
