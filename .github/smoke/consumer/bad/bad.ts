const parsed = JSON.parse("{}");
export const leaked = parsed.value;
export const applied = Reflect.apply(Math.max, undefined, [1, 2]);
