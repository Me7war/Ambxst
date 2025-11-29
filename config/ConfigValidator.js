.pragma library

function clone(obj) {
    return JSON.parse(JSON.stringify(obj));
}

function validate(current, defaults, keyName) {
    // If current is missing, return defaults
    if (current === undefined || current === null) {
        return clone(defaults);
    }

    // If defaults is an array, we generally expect current to be an array.
    // We do NOT merge arrays element-wise (e.g. we don't enforce length or specific items),
    // but we do enforce that it IS an array.
    if (Array.isArray(defaults)) {
        if (!Array.isArray(current)) {
            return clone(defaults);
        }
        return current;
    }

    // If defaults is an object (and not null/array), we recurse.
    if (typeof defaults === 'object') {
        // If current is not an object or is an array, it's the wrong type.
        if (typeof current !== 'object' || Array.isArray(current)) {
            return clone(defaults);
        }

        var result = {};
        // We iterate over DEFAULTS keys. 
        // 1. This ensures we include all keys from defaults (Add missing).
        // 2. This ensures we ONLY include keys from defaults (Remove extras).
        for (var key in defaults) {
            result[key] = validate(current[key], defaults[key], key);
        }
        return result;
    }

    // For primitive types (string, number, boolean)
    // We check if the type matches.
    if (typeof current !== typeof defaults) {
        // Special case: Int vs Float. In JS they are both 'number'.
        // So this check passes for 1 vs 1.0.
        return defaults;
    }

    // Specific validations
    if (keyName === "gradientType") {
        var validTypes = ["linear", "radial", "halftone"];
        if (validTypes.indexOf(current) === -1) {
            return defaults;
        }
    }

    return current;
}
