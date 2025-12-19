import { useState, useRef, useEffect } from 'react';
import axios from 'axios';
import { motion, AnimatePresence } from 'framer-motion';
import { Send, Smile, Paperclip, Bot, User, Sparkles, Plus, MessageSquare } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export default function Chat() {
    const { user } = useAuth();
    const [messages, setMessages] = useState([]);
    const [sessions, setSessions] = useState([]);
    const [input, setInput] = useState('');
    const [isTyping, setIsTyping] = useState(false);
    const scrollRef = useRef(null);
    const [currentSessionId, setCurrentSessionId] = useState(null);

    // Fetch Sessions on mount
    useEffect(() => {
        if (user) fetchSessions();
    }, [user]);

    // Fetch Messages when session changes
    useEffect(() => {
        if (user) {
            if (currentSessionId) {
                fetchMessages(currentSessionId);
            } else {
                // Default: Start fresh or load nothing
                setMessages([{ id: 0, role: 'ai', text: "Hello! Always here if you need to talk.", created_at: new Date().toISOString() }]);
            }
        }
    }, [currentSessionId, user]);

    // Scroll to bottom whenever messages change
    useEffect(() => {
        if (scrollRef.current) {
            scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
        }
    }, [messages, isTyping]);

    const fetchSessions = async () => {
        try {
            const res = await axios.get(`http://localhost:8000/api/chat/sessions?user_id=${user.id}`);
            setSessions(res.data);
        } catch (e) { console.error(e); }
    };

    const fetchMessages = async (sessionId) => {
        try {
            const res = await axios.get(`http://localhost:8000/api/chat/history?user_id=${user.id}&session_id=${sessionId}`);
            setMessages(res.data.map(m => ({
                id: m.id,
                role: m.role === 'assistant' ? 'ai' : 'user',
                text: m.message,
                created_at: m.created_at
            })));
        } catch (e) { console.error(e); }
    };

    const handleNewChat = () => {
        setCurrentSessionId(null);
        setMessages([{ id: 0, role: 'ai', text: "Hey! New conversation started. How can I help?", created_at: new Date().toISOString() }]);
    };

    const handleSend = async () => {
        if (!input.trim() || !user) return;

        // Optimistic UI
        const newMsg = { id: Date.now(), role: 'user', text: input, created_at: new Date().toISOString() };

        // Append user message immediately
        setMessages(prev => [...prev, newMsg]);
        setInput('');
        setIsTyping(true);

        try {
            // Note: If currentSessionId is null, backend generates a new one.
            const res = await axios.post('http://localhost:8000/api/chat/send', {
                user_id: user.id,
                session_id: currentSessionId,
                message: newMsg.text
            });

            // If we started a new session, update state
            if (!currentSessionId || currentSessionId !== res.data.session_id) {
                setCurrentSessionId(res.data.session_id);
                // We don't want to re-fetch sessions immediately if it disrupts the flow, 
                // but let's do it quietly to update sidebar
                fetchSessions();
            }

            setIsTyping(false);

            // Append AI response
            setMessages(prev => [...prev, {
                id: Date.now() + 1,
                role: 'ai',
                text: res.data.reply,
                created_at: new Date().toISOString()
            }]);
        } catch (e) {
            console.error(e);
            setIsTyping(false);
            // Optionally remove the optimistic message on failure or show error
        }
    };

    const handleKeyPress = (e) => {
        if (e.key === 'Enter') handleSend();
    };

    const formatTime = (isoString) => {
        if (!isoString) return '';
        return new Date(isoString).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    };

    return (
        <div className="h-screen pt-16 flex flex-col md:flex-row overflow-hidden bg-[#09090b]">

            {/* Sidebar (Session History) */}
            <div className="w-full md:w-80 h-1/4 md:h-full border-b md:border-b-0 md:border-r border-white/5 bg-black/20 flex flex-col p-4">
                <button
                    onClick={handleNewChat}
                    className="w-full mb-6 p-3 rounded-xl bg-primary hover:bg-primary-glow text-white font-medium flex items-center justify-center gap-2 transition-all shadow-lg shadow-primary/20 shrink-0"
                >
                    <Plus size={20} /> New Chat
                </button>

                <h3 className="text-xs uppercase tracking-widest text-gray-500 font-bold mb-3 pl-2 shrink-0">History</h3>
                <div className="flex-1 overflow-y-auto space-y-2 pr-2 custom-scrollbar">
                    {sessions.map(s => (
                        <button
                            key={s.session_id}
                            onClick={() => setCurrentSessionId(s.session_id)}
                            className={`w-full text-left p-3 rounded-lg text-sm transition-all flex items-center gap-3 group relative overflow-hidden shrink-0 ${currentSessionId === s.session_id
                                    ? 'bg-white/10 text-white'
                                    : 'bg-transparent text-gray-400 hover:bg-white/5 hover:text-white'
                                }`}
                        >
                            <MessageSquare size={16} className={currentSessionId === s.session_id ? 'text-primary' : ''} />
                            <span className="truncate flex-1">{s.preview}</span>
                        </button>
                    ))}
                    {sessions.length === 0 && (
                        <div className="text-gray-600 text-sm text-center py-4">No history yet.</div>
                    )}
                </div>
            </div>

            {/* Main Chat Area - Uses Flex Column for Perfect Layout */}
            <div className="flex-1 flex flex-col h-[75vh] md:h-full relative overflow-hidden">
                {/* 1. Header (Fixed Height) */}
                <div className="p-4 border-b border-white/5 bg-black/40 backdrop-blur-md flex items-center justify-between z-10 w-full shrink-0">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-primary to-neon-blue flex items-center justify-center shadow-lg shadow-primary/20">
                            <Bot size={20} className="text-white" />
                        </div>
                        <div>
                            <h2 className="font-bold text-white">AI Companion</h2>
                            <p className="text-xs text-primary-light flex items-center gap-1">
                                <Sparkles size={10} /> Empathetic & Supportive
                            </p>
                        </div>
                    </div>
                </div>

                {/* 2. Messages (Takes remaining height, scrolls internally) */}
                <div ref={scrollRef} className="flex-1 overflow-y-auto p-4 md:p-8 space-y-6 custom-scrollbar">
                    {messages.map((msg) => (
                        <motion.div
                            key={msg.id}
                            initial={{ opacity: 0, y: 10, scale: 0.95 }}
                            animate={{ opacity: 1, y: 0, scale: 1 }}
                            className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
                        >
                            <div className={`max-w-[85%] md:max-w-[65%] p-4 md:p-5 rounded-2xl shadow-xl relative backdrop-blur-sm ${msg.role === 'user'
                                    ? 'bg-primary text-white rounded-tr-sm'
                                    : 'bg-[#18181b] border border-white/10 text-gray-200 rounded-tl-sm'
                                }`}>
                                <p className="text-sm md:text-base leading-relaxed whitespace-pre-wrap">{msg.text}</p>
                                <span className={`text-[10px] absolute bottom-1 right-3 ${msg.role === 'user' ? 'text-blue-200' : 'text-gray-500'}`}>
                                    {formatTime(msg.created_at)}
                                </span>
                            </div>
                        </motion.div>
                    ))}
                    {isTyping && (
                        <div className="flex justify-start">
                            <div className="bg-[#18181b] border border-white/10 p-4 rounded-2xl rounded-tl-none flex gap-1 items-center">
                                <motion.div animate={{ y: [0, -5, 0] }} transition={{ repeat: Infinity, duration: 0.6 }} className="w-2 h-2 bg-gray-500 rounded-full" />
                                <motion.div animate={{ y: [0, -5, 0] }} transition={{ repeat: Infinity, duration: 0.6, delay: 0.2 }} className="w-2 h-2 bg-gray-500 rounded-full" />
                                <motion.div animate={{ y: [0, -5, 0] }} transition={{ repeat: Infinity, duration: 0.6, delay: 0.4 }} className="w-2 h-2 bg-gray-500 rounded-full" />
                            </div>
                        </div>
                    )}
                </div>

                {/* 3. Input Area (Fixed Height, Stays at Bottom) */}
                <div className="p-4 bg-black/60 backdrop-blur-xl border-t border-white/5 shrink-0">
                    <div className="max-w-4xl mx-auto flex gap-3">
                        <div className="flex-1 relative">
                            <input
                                type="text"
                                className="w-full bg-[#18181b] border border-white/10 rounded-2xl px-6 py-4 pr-12 text-white placeholder-gray-500 focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-all shadow-inner"
                                placeholder="Type a message..."
                                value={input}
                                onChange={e => setInput(e.target.value)}
                                onKeyDown={handleKeyPress}
                            />
                            <button className="absolute right-3 top-1/2 -translate-y-1/2 p-2 rounded-full hover:bg-white/5 text-gray-400 hover:text-primary-light transition-colors">
                                <Smile size={20} />
                            </button>
                        </div>
                        <button
                            onClick={handleSend}
                            disabled={!input.trim()}
                            className="p-4 rounded-2xl bg-primary hover:bg-primary-glow hover:scale-105 active:scale-95 transition-all text-white shadow-lg shadow-primary/20 disabled:opacity-50 disabled:hover:scale-100"
                        >
                            <Send size={20} />
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}
