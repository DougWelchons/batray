import { useHeader } from '../HeaderContext';

export default function BidSubmissions() {
  useHeader('Bid Submissions');

  return (
    <div className="px-4 sm:px-0">
      <p className="mt-4 text-gray-600">
        Bid Submissions page - ready to connect to API
      </p>
    </div>
  );
}
