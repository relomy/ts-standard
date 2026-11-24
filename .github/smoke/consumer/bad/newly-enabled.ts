export const chained = JSON.parse("1") as unknown as number;
export function takesObject(options: object): string {
  return String(options);
}
export const fetched = Reflect.get({ a: 1 }, "a");
