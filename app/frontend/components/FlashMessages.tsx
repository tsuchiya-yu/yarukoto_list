import { usePage } from "@inertiajs/react";

import type { PageProps } from "@/types/page";

export function FlashMessages() {
  const { flash } = usePage<PageProps>().props;
  if (!flash) {
    return null;
  }

  const { notice, alert } = flash;
  const messages = [
    notice && { type: "notice" as const, text: notice },
    alert && { type: "alert" as const, text: alert }
  ].filter((message): message is { type: "notice" | "alert"; text: string } => Boolean(message));

  if (messages.length === 0) {
    return null;
  }

  return (
    <div className="flash-messages">
      {messages.map((message) => (
        <p key={message.type} className={`flash flash--${message.type}`}>
          {message.text}
        </p>
      ))}
    </div>
  );
}
