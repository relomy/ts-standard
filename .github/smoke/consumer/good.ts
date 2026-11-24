export function double(value: number): number {
  return value * 2;
}

// oxlint-disable-next-line eslint/eqeqeq -- fixture: a directive with a reason passes
export const same = (left: number, right: number) => left == right;

export type Payload = unknown;
