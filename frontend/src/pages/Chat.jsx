import { useState, useRef, useEffect } from 'react';
import axios from 'axios';
import { motion, AnimatePresence } from 'framer-motion';
import { Send, Smile, Paperclip, Bot, User, Sparkles } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function Chat() {
    const { user } = useAuth();
    const [messages, setMessages] = useState([]);
    const [input, setInput] = useState('');
    const [isTyping, setIsTyping] = useState(false);
    const scrollRef = useRef(null);
    const sessionId = useRef(null); // Keep persistent session

    useEffect(() => {
        const fetchHistory = async () => {
            if (!user) return;
            try {
                // Fetch last session if any, or just all history for user
                const res = await axios.get(`http://localhost:8000/api/chat/history?user_id=${user.id}&limit=20`);
                if (res.data && res.data.length > 0) {
                    setMessages(res.data.map(m => ({ id: m.id, role: m.role === 'assistant' ? 'ai' : 'user', text: m.message })));
                } else {
                    setMessages([{ id: 0, role: 'ai', text: "Hello! I noticed you might be feeling a bit low today. Want to talk about it?" }]);
                }
            } catch (e) { console.error(e); }
        };
        fetchHistory();
    }, [user]);

    useEffect(() => {
        if (scrollRef.current) scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }, [messages, isTyping]);

    const handleSend = async () => {
        if (!input.trim() || !user) return;

        // Optimistic UI
        const userMsg = { id: Date.now(), role: 'user', text: input };
        setMessages(prev => [...prev, userMsg]);
        setInput('');
        setIsTyping(true);

        try {
            const res = await axios.post('http://localhost:8000/api/chat/send', {
                user_id: user.id,
                session_id: sessionId.current,
                message: userMsg.text
            });
            sessionId.current = res.data.session_id; // update session

            setIsTyping(false);
            setMessages(prev => [...prev, {
                id: Date.now() + 1,
                role: 'ai',
                text: res.data.reply
            }]);
        } catch (e) {
            console.error(e);
            setIsTyping(false);
        }
    };

    const handleKeyPress = (e) => {
        if (e.key === 'Enter') handleSend();
    };

    return (
        <div className="h-screen pt-16 flex md:flex-row flex-col overflow-hidden bg-dark">
            {/* Main Chat Area */}
            <div className="flex-1 flex flex-col relative">
                {/* Chat Header */}
                <div className="p-4 border-b border-white/5 bg-dark/50 backdrop-blur-md flex items-center justify-between z-10 absolute top-0 w-full">
                    <div className="flex items-center gap-3">
                        <div className="relative">
                            <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-primary to-neon-blue flex items-center justify-center">
                                <Bot size={20} className="text-white" />
                            </div>
                            <div className="absolute bottom-0 right-0 w-3 h-3 bg-green-500 rounded-full border-2 border-dark" />
                        </div>
                        <div>
                            <h2 className="font-bold">AI Companion</h2>
                            <p className="text-xs text-primary-light flex items-center gap-1">
                                <Sparkles size={10} /> Empathetic & Supportive
                            </p>
                        </div>
                    </div>
                </div>

                {/* Messages */}
                <div ref={scrollRef} className="flex-1 overflow-y-auto p-4 pt-20 pb-24 space-y-6">
                    {messages.map((msg) => (
                        <motion.div
                            key={msg.id}
                            initial={{ opacity: 0, y: 10, scale: 0.95 }}
                            animate={{ opacity: 1, y: 0, scale: 1 }}
                            className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
                        >
                            <div className={`max-w-[80%] md:max-w-[60%] p-4 rounded-2xl shadow-lg relative ${msg.role === 'user'
                                ? 'bg-primary text-white rounded-tr-none'
                                : 'bg-white/10 text-gray-100 rounded-tl-none border border-white/5'
                                }`}>
                                <p className="text-sm md:text-base leading-relaxed">{msg.text}</p>
                                <span className="text-[10px] opacity-50 absolute bottom-1 right-3">10:42 AM</span>
                            </div>
                        </motion.div>
                    ))}
                    {isTyping && (
                        <div className="flex justify-start">
                            <div className="bg-white/5 p-4 rounded-2xl rounded-tl-none border border-white/5 flex gap-1 items-center">
                                <motion.div animate={{ y: [0, -5, 0] }} transition={{ repeat: Infinity, duration: 0.6 }} className="w-2 h-2 bg-gray-500 rounded-full" />
                                <motion.div animate={{ y: [0, -5, 0] }} transition={{ repeat: Infinity, duration: 0.6, delay: 0.2 }} className="w-2 h-2 bg-gray-500 rounded-full" />
                                <motion.div animate={{ y: [0, -5, 0] }} transition={{ repeat: Infinity, duration: 0.6, delay: 0.4 }} className="w-2 h-2 bg-gray-500 rounded-full" />
                            </div>
                        </div>
                    )}
                </div>

                {/* Input Area */}
                <div className="absolute bottom-0 w-full p-4 bg-dark/80 backdrop-blur-xl border-t border-white/5">
                    <div className="max-w-4xl mx-auto flex gap-3">
                        <button className="p-3 rounded-xl bg-white/5 hover:bg-white/10 text-gray-400 transition-colors">
                            <Paperclip size={20} />
                        </button>
                        <div className="flex-1 relative">
                            <input
                                type="text"
                                className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 pr-12 text-white placeholder-gray-500 focus:outline-none focus:border-primary/50 transition-colors"
                                placeholder="Type a message..."
                                value={input}
                                onChange={e => setInput(e.target.value)}
                                onKeyDown={handleKeyPress}
                            />
                            <button className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-primary-light">
                                <Smile size={20} />
                            </button>
                        </div>
                        <button onClick={handleSend} className="p-3 rounded-xl bg-primary hover:scale-105 active:scale-95 transition-all text-white shadow-lg shadow-primary/20">
                            <Send size={20} />
                        </button>
                    </div>
                </div>
            </div>

            {/* Sidebar (Desktop) */}
            <div className="hidden md:flex w-80 border-l border-white/5 bg-dark-card/30 flex-col p-6">
                <h3 className="font-bold text-gray-400 text-xs uppercase tracking-widest mb-6">Current Mood</h3>
                <div className="flex flex-col gap-4">
                    <div className="p-4 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between">
                        <span>Happy</span>
                        <span>😊</span>
                    </div>
                    <div className="p-4 rounded-xl bg-white/5 border border-white/5 flex items-center justify-between opacity-50">
                        <span>Calm</span>
                        <span>😌</span>
                    </div>
                </div>

                <h3 className="font-bold text-gray-400 text-xs uppercase tracking-widest mt-8 mb-6">Suggested Actions</h3>
                <div className="space-y-3">
                    <button className="w-full p-3 rounded-lg text-left text-sm bg-primary/10 text-primary-light border border-primary/20 hover:bg-primary/20 transition-colors">
                        Tell me a joke
                    </button>
                    <button className="w-full p-3 rounded-lg text-left text-sm bg-white/5 text-gray-300 border border-white/10 hover:bg-white/10 transition-colors">
                        Give me a micro-task
                    </button>
                </div>
            </div>
        </div>
    );
}
