type Variant = "field" | "form";

type Props = {
  messages?: string | string[];
  variant?: Variant;
  className?: string;
  keyPrefix?: string;
};

const classMap: Record<Variant, string> = {
  field: "input-error",
  form: "form-error"
};

export function FormErrorMessages({
  messages,
  variant = "field",
  className,
  keyPrefix
}: Props) {
  if (!messages || (Array.isArray(messages) && messages.length === 0)) {
    return null;
  }

  const resolvedMessages = Array.isArray(messages) ? messages : [messages];
  const baseClass = classMap[variant];
  const combinedClassName = [baseClass, className].filter(Boolean).join(" ");
  const prefix = keyPrefix ?? variant;

  return (
    <>
      {resolvedMessages.map((message, index) => (
        <p key={`${prefix}-${message}-${index}`} className={combinedClassName}>
          {message}
        </p>
      ))}
    </>
  );
}
