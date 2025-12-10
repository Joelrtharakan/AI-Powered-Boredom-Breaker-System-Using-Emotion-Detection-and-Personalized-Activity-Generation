
import { useState } from 'react';
import { NavLink, useNavigate, useLocation } from 'react-router-dom';
import { Menu, X, Home, Gamepad2, Music, Book, Lock, Mic, MessageCircle, BarChart2, LogOut } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { motion, AnimatePresence } from 'framer-motion';

const SidebarItem = ({ icon: Icon, label, to, onClick }) => {
    const location = useLocation();
    const isActive = location.pathname === to;

    return (
        <NavLink
            to={to}
            onClick={onClick}
            className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all duration-200 group ${isActive
                    ? 'bg-primary text-white shadow-lg shadow-primary/25'
                    : 'text-gray-400 hover:bg-white/5 hover:text-white'
                }`}
        >
            <Icon size={20} className={isActive ? 'text-white' : 'text-gray-400 group-hover:text-white'} />
            <span className="font-medium">{label}</span>
            {isActive && <motion.div layoutId="active-pill" className="absolute left-0 w-1 h-8 bg-white rounded-r-full" />}
        </NavLink>
    );
};

export default function Layout({ children }) {
    const [isOpen, setIsOpen] = useState(false);
    const { logout } = useAuth();
    const navigate = useNavigate();

    const handleLogout = () => {
        logout();
        navigate('/login');
    };

    const toggleSidebar = () => setIsOpen(!isOpen);

    const navItems = [
        { icon: Home, label: 'Dashboard', to: '/dashboard' },
        { icon: Gamepad2, label: 'Mini Games', to: '/games' },
        { icon: Music, label: 'Music', to: '/music' },
        { icon: Book, label: 'Journal', to: '/journal' },
        { icon: Mic, label: 'Voice Mode', to: '/voice' },
        { icon: MessageCircle, label: 'AI Friend', to: '/chat' },
        { icon: Lock, label: 'Lockbox', to: '/lockbox' },
        { icon: BarChart2, label: 'History', to: '/history' },
    ];

    return (
        <div className="min-h-screen bg-background text-white flex">
            {/* Mobile Hamburger */}
            <div className="md:hidden fixed top-4 left-4 z-50">
                <button
                    onClick={toggleSidebar}
                    className="p-3 rounded-full bg-surface border border-white/10 shadow-lg text-white"
                >
                    {isOpen ? <X size={24} /> : <Menu size={24} />}
                </button>
            </div>

            {/* Sidebar Overlay (Mobile) */}
            <AnimatePresence>
                {isOpen && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={() => setIsOpen(false)}
                        className="md:hidden fixed inset-0 bg-black/80 backdrop-blur-sm z-40"
                    />
                )}
            </AnimatePresence>

            {/* Sidebar */}
            <motion.aside
                className={`fixed md:sticky top-0 left-0 h-screen w-72 bg-surface border-r border-white/5 z-40 flex flex-col p-6 overflow-y-auto
                ${isOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'}
                transition-transform duration-300 ease-in-out`}
            >
                <div className="mb-10 flex items-center gap-3 px-2">
                    <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-primary to-secondary" />
                    <h1 className="text-xl font-bold tracking-tight">Boredom<span className="text-primary">Breaker</span></h1>
                </div>

                <nav className="flex-1 space-y-2">
                    {navItems.map((item) => (
                        <SidebarItem
                            key={item.to}
                            {...item}
                            onClick={() => setIsOpen(false)} // Close on mobile click
                        />
                    ))}
                </nav>

                <div className="pt-6 mt-6 border-t border-white/5">
                    <button
                        onClick={handleLogout}
                        className="flex items-center gap-3 px-4 py-3 rounded-xl text-gray-400 hover:bg-red-500/10 hover:text-red-400 w-full transition-colors"
                    >
                        <LogOut size={20} />
                        <span className="font-medium">Sign Out</span>
                    </button>
                </div>
            </motion.aside>

            {/* Main Content */}
            <main className="flex-1 min-w-0 relative">
                {children}
            </main>
        </div>
    );
}
