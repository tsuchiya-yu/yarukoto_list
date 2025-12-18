export const formatDate = (value: string) =>
  new Date(value).toLocaleDateString("ja-JP", { year: "numeric", month: "short", day: "numeric" });

export const formatScore = (value: number) => value.toFixed(1);
