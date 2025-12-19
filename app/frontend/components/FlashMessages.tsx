import { usePage } from "@inertiajs/react";

import type { PageProps } from "@/types/page";

export function FlashMessages() {
  const { flash } = usePage<PageProps>().props;
  if (!flash) {
    return null;
  }

  const messages: { type: "notice" | "alert"; text: string }[] = [];
  if (flash.notice) {
    messages.push({ type: "notice", text: flash.notice });
  }
  if (flash.alert) {
    messages.push({ type: "alert", text: flash.alert });
  }

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
