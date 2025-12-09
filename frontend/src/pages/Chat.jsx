export default function Chat() {
    return (
        <div className="p-8 max-w-7xl mx-auto min-h-screen flex flex-col">
            <div className="mb-4">
                <h1 className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-red-400 to-pink-500 mb-2">AI Companion</h1>
                <p className="text-gray-300">Your empathetic friend, always here.</p>
            </div>

            <div className="flex-1 glass-card flex flex-col overflow-hidden max-h-[70vh]">
                <div className="flex-1 p-4 overflow-y-auto space-y-4">
                    <div className="self-start bg-white/10 rounded-lg p-3 max-w-[80%] rounded-tl-none">
                        Hello! I noticed you might be feeling a bit low today. Want to talk about it?
                    </div>
                    <div className="self-end bg-primary/20 rounded-lg p-3 max-w-[80%] rounded-tr-none ml-auto text-right">
                        Yeah, just a boring day.
                    </div>
                </div>
                <div className="p-4 border-t border-white/10 flex gap-4">
                    <input type="text" placeholder="Type a message..." className="input-field" />
                    <button className="btn-primary">Send</button>
                </div>
            </div>
        </div>
    )
}
